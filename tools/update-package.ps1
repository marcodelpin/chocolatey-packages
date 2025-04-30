param (
    [Parameter(Mandatory=$true)]
    [string]$package_name,
    
    [Parameter(Mandatory=$true)]
    [string]$new_version,
    
    [Parameter(Mandatory=$false)]
    [string]$new_url = $null,
    
    [Parameter(Mandatory=$false)]
    [string]$new_checksum = $null,
    
    [Parameter(Mandatory=$false)]
    [string]$checksum_type = "sha256"
)

$error_message = "An error occurred while updating the package $package_name."
$package_dir = Join-Path $PSScriptRoot "..\packages\$package_name"
$nuspec_file = Join-Path $package_dir "$package_name.nuspec"
$install_script = Join-Path $package_dir "tools\chocolateyInstall.ps1"

function Update-NuspecVersion {
    param (
        [string]$nuspec_file,
        [string]$new_version
    )
    
    try {
        [xml]$nuspec = Get-Content $nuspec_file
        $current_version = $nuspec.package.metadata.version
        
        Write-Host "Updating version in nuspec from $current_version to $new_version"
        $nuspec.package.metadata.version = $new_version
        
        # Update release notes
        $update_date = Get-Date -Format "yyyy-MM-dd"
        $release_note = "Updated to version $new_version on $update_date"
        
        if ($nuspec.package.metadata.releaseNotes) {
            $nuspec.package.metadata.releaseNotes = "$release_note`n`n" + $nuspec.package.metadata.releaseNotes
        } else {
            $nuspec.package.metadata.releaseNotes = $release_note
        }
        
        $nuspec.Save($nuspec_file)
        Write-Host "Nuspec file updated successfully" -ForegroundColor Green
    } catch {
        Write-Error $error_message
        Write-Error $_.Exception.Message
        exit 1
    }
}

function Update-InstallScript {
    param (
        [string]$install_script,
        [string]$new_version,
        [string]$new_url = $null,
        [string]$new_checksum = $null
    )
    
    try {
        $content = Get-Content $install_script -Raw
        
        # Update version
        $content = [regex]::Replace($content, '(\$version\s*=\s*[''"]).*?([''"])', "`$1$new_version`$2")
        
        # Update URL if provided
        if ($new_url) {
            $content = [regex]::Replace($content, '(\$url\s*=\s*[''"]).*?([''"])', "`$1$new_url`$2")
        }
        
        # Update checksum if provided
        if ($new_checksum) {
            $content = [regex]::Replace($content, '(\$checksum\s*=\s*[''"]).*?([''"])', "`$1$new_checksum`$2")
        }
        
        Set-Content -Path $install_script -Value $content
        Write-Host "Install script updated successfully" -ForegroundColor Green
    } catch {
        Write-Error $error_message
        Write-Error $_.Exception.Message
        exit 1
    }
}

function Generate-Checksum {
    param (
        [string]$url,
        [string]$checksum_type = "sha256"
    )
    
    try {
        $temp_file = Join-Path $env:TEMP ([System.IO.Path]::GetFileName($url))
        
        Write-Host "Downloading file to calculate checksum..."
        Invoke-WebRequest -Uri $url -OutFile $temp_file
        
        $calculated_checksum = Get-FileHash -Path $temp_file -Algorithm $checksum_type | Select-Object -ExpandProperty Hash
        Remove-Item $temp_file -Force
        
        return $calculated_checksum
    } catch {
        Write-Error "Failed to calculate checksum for $url"
        Write-Error $_.Exception.Message
        return $null
    }
}

# Main execution
if (-not (Test-Path $package_dir)) {
    Write-Error "Package directory for $package_name not found at $package_dir"
    exit 1
}

if (-not (Test-Path $nuspec_file)) {
    Write-Error "Nuspec file not found at $nuspec_file"
    exit 1
}

if (-not (Test-Path $install_script)) {
    Write-Error "Install script not found at $install_script"
    exit 1
}

# If URL is provided but no checksum, generate one
if ($new_url -and -not $new_checksum) {
    Write-Host "URL provided without checksum. Attempting to calculate checksum..."
    $new_checksum = Generate-Checksum -url $new_url -checksum_type $checksum_type
    
    if ($new_checksum) {
        Write-Host "Generated $checksum_type checksum: $new_checksum" -ForegroundColor Green
    } else {
        Write-Error "Failed to generate checksum. Please provide it manually."
        exit 1
    }
}

# Update the files
Update-NuspecVersion -nuspec_file $nuspec_file -new_version $new_version
Update-InstallScript -install_script $install_script -new_version $new_version -new_url $new_url -new_checksum $new_checksum

# Pack the updated package
$current_location = Get-Location
Set-Location $package_dir
Write-Host "Packing updated package..."

try {
    choco pack
    Write-Host "Package updated and packed successfully!" -ForegroundColor Green
    Write-Host "Package file created at: $package_dir\$package_name.$new_version.nupkg"
} catch {
    Write-Error "Failed to pack the package"
    Write-Error $_.Exception.Message
} finally {
    Set-Location $current_location
}