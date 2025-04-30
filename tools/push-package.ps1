# Script to push Chocolatey packages while keeping API key secure
param (
    [Parameter(Mandatory=$true)]
    [string]$package_name,
    
    [Parameter(Mandatory=$false)]
    [string]$specific_nupkg = "",
    
    [Parameter(Mandatory=$false)]
    [string]$api_key_file = "$env:USERPROFILE\.chocolatey\api_key.txt",
    
    [Parameter(Mandatory=$false)]
    [string]$push_source = "https://push.chocolatey.org/",
    
    [Parameter(Mandatory=$false)]
    [switch]$verify_only = $false,
    
    [Parameter(Mandatory=$false)]
    [switch]$force = $false
)

$error_message = "An error occurred during push operation."
$script_path = Split-Path -Parent $MyInvocation.MyCommand.Definition
$repo_root = Split-Path -Parent $script_path
$package_dir = Join-Path $repo_root "packages\$package_name"
$today_date = Get-Date -Format "yyyyMMdd"
$backup_dir = Join-Path $env:TEMP "choco_backup_$today_date"
$verbose_output = $false  # Set to $true for more verbose output

function Check_Requirements {
    # Check if package exists
    if (-not (Test-Path $package_dir) -and -not $verify_only) {
        Write-Error "Package directory '$package_name' not found at: $package_dir"
        exit 1
    }
    
    # Check if API key file exists, create if not
    if (-not (Test-Path $api_key_file)) {
        $api_key_folder = Split-Path -Parent $api_key_file
        if (-not (Test-Path $api_key_folder)) {
            New-Item -ItemType Directory -Path $api_key_folder -Force | Out-Null
        }
        
        $api_key = Read-Host "Chocolatey API key not found. Please enter your API key (it will be stored securely)" -AsSecureString
        $api_key_plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($api_key))
        $api_key_encrypted = ConvertTo-SecureString -String $api_key_plain -AsPlainText -Force | ConvertFrom-SecureString
        $api_key_encrypted | Set-Content -Path $api_key_file
        
        Write-Host "API key stored securely at $api_key_file" -ForegroundColor Green
    }
}

function Verify_API_Key {
    Write-Host "Verifying API key file at: $api_key_file" -ForegroundColor Yellow
    
    if (-not (Test-Path $api_key_file)) {
        Write-Error "API key file not found at: $api_key_file"
        return $false
    }
    
    try {
        # Try to read and decrypt the API key
        $api_key_encrypted = Get-Content -Path $api_key_file -ErrorAction Stop
        
        try {
            $api_key = ConvertTo-SecureString -String $api_key_encrypted -ErrorAction Stop
            $api_key_plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($api_key))
            
            if ([string]::IsNullOrWhiteSpace($api_key_plain)) {
                Write-Error "API key is empty or could not be decrypted correctly"
                return $false
            }
            
            # Only show the first few characters for verification
            $masked_key = $api_key_plain.Substring(0, [Math]::Min(4, $api_key_plain.Length)) + "..." 
            Write-Host "API key file read successfully. Key starts with: $masked_key" -ForegroundColor Green
            return $true
        }
        catch {
            Write-Error "Failed to decrypt API key: $_"
            Write-Host "The API key file exists but appears to be in an invalid format." -ForegroundColor Yellow
            Write-Host "If you created this file manually, it needs to be encrypted using PowerShell's ConvertFrom-SecureString." -ForegroundColor Yellow
            Write-Host "Consider deleting the file and letting this script recreate it properly on the next run." -ForegroundColor Yellow
            return $false
        }
    }
    catch {
        Write-Error "Failed to read API key file: $_"
        return $false
    }
}

function Find_Latest_Package {
    # If a specific package file is specified, use that
    if (-not [string]::IsNullOrEmpty($specific_nupkg)) {
        $specified_path = ""
        
        # Check if the provided path is absolute or relative
        if ([System.IO.Path]::IsPathRooted($specific_nupkg)) {
            $specified_path = $specific_nupkg
        } else {
            # Treat as relative to package directory
            $specified_path = Join-Path $package_dir $specific_nupkg
        }
        
        if (Test-Path $specified_path) {
            Write-Host "Using specified package: $specified_path" -ForegroundColor Green
            return $specified_path
        } else {
            Write-Error "Specified package '$specific_nupkg' not found."
            return $null
        }
    }

    # Find the latest .nupkg file
    $nupkg_files = Get-ChildItem -Path $package_dir -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending
    
    if ($nupkg_files.Count -eq 0) {
        Write-Host "No .nupkg file found. Attempting to create one..." -ForegroundColor Yellow
        
        $current_location = Get-Location
        Set-Location $package_dir
        
        try {
            choco pack
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to pack the package"
                return $null
            }
        }
        catch {
            Write-Error "Error packing the package: $_"
            return $null
        }
        finally {
            Set-Location $current_location
        }
        
        $nupkg_files = Get-ChildItem -Path $package_dir -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending
        
        if ($nupkg_files.Count -eq 0) {
            Write-Error "Still no .nupkg file found after attempting to create one"
            return $null
        }
    }
    
    if ($nupkg_files.Count -gt 1 -and -not $force) {
        Write-Host "Multiple package versions found:" -ForegroundColor Yellow
        for ($i = 0; $i -lt [Math]::Min(5, $nupkg_files.Count); $i++) {
            Write-Host "  $($i+1). $($nupkg_files[$i].Name)" -ForegroundColor Cyan
        }
        
        Write-Host "`nTo push a specific version, use: .\tools\push-package.ps1 -package_name fsviewer -specific_nupkg 'fsviewer.7.8.0.20250501.nupkg'" -ForegroundColor Yellow
        Write-Host "Or to use the latest version, add the -force parameter" -ForegroundColor Yellow
        
        return $null
    }
    
    return $nupkg_files[0].FullName
}

function Push_Package {
    param (
        [string]$package_path
    )
    
    # Read API key from secure file
    $api_key_encrypted = Get-Content -Path $api_key_file
    $api_key = ConvertTo-SecureString -String $api_key_encrypted
    $api_key_plain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($api_key))
    
    # Push package
    Write-Host "Pushing package $package_name to Chocolatey..." -ForegroundColor Cyan
    
    try {
        # First make sure API key is configured
        if ($verbose_output) {
            Write-Host "Configuring API key for $push_source..." -ForegroundColor DarkGray
        }
        
        # Set the API key (this step previously failed to apply correctly)
        $api_key_result = & choco apikey --key="$api_key_plain" --source="$push_source" 2>&1
        foreach ($line in $api_key_result) {
            Write-Host $line -ForegroundColor DarkGray
        }
        
        # Push the package with the API key explicitly included
        Write-Host "Running: choco push '$package_path' --source='$push_source' --api-key=<hidden>" -ForegroundColor DarkGray
        
        # Extract package name and version from the filename for better error reporting
        $package_filename = Split-Path -Leaf $package_path
        $package_pattern = "^(.+?)\.([0-9]+\.[0-9]+\.[0-9]+(?:\.[0-9]+)?)\.nupkg$"
        if ($package_filename -match $package_pattern) {
            $pkg_id = $matches[1]
            $pkg_version = $matches[2]
            Write-Host "Pushing package ID: $pkg_id, Version: $pkg_version" -ForegroundColor DarkGray
        }
        
        # Pass the API key directly with the push command
        $output = & choco push "$package_path" --source="$push_source" --api-key="$api_key_plain" 2>&1
        $exit_code = $LASTEXITCODE
        
        # Display the output
        foreach ($line in $output) {
            if ($line -match "error|fail|exception") {
                Write-Host $line -ForegroundColor Red
            } else {
                Write-Host $line
            }
        }
        
        if ($exit_code -eq 0) {
            Write-Host "Successfully pushed $package_name to Chocolatey!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "Failed to push package to Chocolatey. Exit code: $exit_code" -ForegroundColor Red
            
            # Provide more information based on common error codes
            switch ($exit_code) {
                1 { 
                    Write-Host "Error code 1 usually indicates authentication failure or the package already exists." -ForegroundColor Yellow
                    Write-Host "Check if the package already exists on chocolatey.org or if your API key is correct." -ForegroundColor Yellow
                }
                5 { 
                    Write-Host "Error code 5 often indicates validation errors in the package." -ForegroundColor Yellow 
                }
                default { 
                    Write-Host "For more information about this error, check: https://docs.chocolatey.org/en-us/create/commands/push" -ForegroundColor Yellow
                }
            }
            
            return $false
        }
    }
    catch {
        Write-Host "Exception occurred during push operation: $_" -ForegroundColor Red
        return $false
    }
}

function Backup_Package {
    param (
        [string]$package_path
    )
    
    # Create backup directory if it doesn't exist
    if (-not (Test-Path $backup_dir)) {
        New-Item -ItemType Directory -Path $backup_dir -Force | Out-Null
    }
    
    $package_filename = Split-Path -Leaf $package_path
    $backup_path = Join-Path $backup_dir $package_filename
    
    try {
        Copy-Item -Path $package_path -Destination $backup_path -Force
        Write-Host "Package backed up to $backup_path" -ForegroundColor Green
    }
    catch {
        Write-Warning "Failed to create backup of package: $_"
    }
}

# Main execution flow
try {
    # Check requirements
    Check_Requirements
    
    # Verify API key if requested
    if ($verify_only) {
        $verification_result = Verify_API_Key
        if ($verification_result) {
            Write-Host "API key verification completed successfully!" -ForegroundColor Green
        } else {
            Write-Error "API key verification failed."
            exit 1
        }
        
        exit 0
    }
    
    # Find latest package
    $package_path = Find_Latest_Package
    if (-not $package_path) {
        exit 1
    }
    
    # Backup package before pushing
    Backup_Package -package_path $package_path
    
    # Push package
    $success = Push_Package -package_path $package_path
    
    if ($success) {
        Write-Host "Package publishing process completed successfully" -ForegroundColor Green
        exit 0
    } else {
        Write-Error "Package publishing process failed"
        exit 1
    }
}
catch {
    Write-Error "$error_message $_"
    exit 1
}