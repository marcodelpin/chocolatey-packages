$ErrorActionPreference = 'Stop'; # stop on all errors

$package_name = 'faststone-image-viewer'
$software_name = 'FastStone Image Viewer'
$installer_type = 'EXE' 

$silent_args = '/S'
$valid_exit_codes = @(0)


$uninstalled = $false
$local_key     = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
$machine_key   = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
$machine_key6432 = 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
$key= @()
$key += Get-ItemProperty -Path @($machine_key6432,$machine_key, $local_key) `
                        -ErrorAction SilentlyContinue `
         | ? { $_.DisplayName -like "*$software_name*" }

if ($key.Count -eq 1) {
  $key | % { 
    $file = "$($_.UninstallString)"


    Uninstall-ChocolateyPackage -PackageName $package_name `
                                -FileType $installer_type `
                                -SilentArgs "$silent_args" `
                                -ValidExitCodes $valid_exit_codes `
                                -File "$file"
  }
} elseif ($key.Count -eq 0) {
  Write-Warning "$package_name has already been uninstalled by other means."
} elseif ($key.Count -gt 1) {
  Write-Warning "$key.Count matches found!"
  Write-Warning "To prevent accidental data loss, no programs will be uninstalled."
  Write-Warning "Please alert package maintainer the following keys were matched:"
  $key | % {Write-Warning "- $_.DisplayName"}
}
