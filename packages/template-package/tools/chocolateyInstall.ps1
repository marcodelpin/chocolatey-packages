$error_message   = 'An error occurred during package installation.'
$package_name    = 'template-package'
$tool_name       = 'example-tool'
$version         = '1.0.0'
$url             = 'https://example.com/download/example-tool-1.0.0.exe'
$checksum        = '12345678901234567890123456789012'
$checksum_type   = 'sha256'
$silent_args     = '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-'
$validation_type = 'sha256'

$package_params = @{
  package_name    = $package_name
  file_type       = 'EXE'
  url             = $url
  silent_args     = $silent_args
  checksum        = $checksum
  checksum_type   = $checksum_type
  validation_type = $validation_type
}

try {
  Install-ChocolateyPackage @package_params
  
  $install_location = Join-Path $env:ProgramFiles $tool_name
  
  Write-Host "The $package_name has been installed to $install_location"
} catch {
  Write-Error $error_message
  throw
}