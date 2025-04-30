$error_message    = 'An error occurred during package uninstallation.'
$package_name     = 'template-package'
$software_name    = 'Example Tool*'
$install_location = Join-Path $env:ProgramFiles 'example-tool'

$uninstall_registry_key = Get-UninstallRegistryKey -SoftwareName $software_name

if ($uninstall_registry_key) {
  $uninstall_string = $uninstall_registry_key.UninstallString
  $silent_args = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
  
  $uninstall_params = @{
    package_name    = $package_name
    file_type       = 'EXE'
    file_path       = $uninstall_string
    silent_args     = $silent_args
    valid_exit_codes = @(0)
  }

  try {
    Uninstall-ChocolateyPackage @uninstall_params
    Write-Host "$package_name has been uninstalled."
  } catch {
    Write-Error $error_message
    throw
  }
} else {
  Write-Warning "$package_name does not appear to be installed. Skipping."
}