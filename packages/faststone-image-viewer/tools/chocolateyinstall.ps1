$ErrorActionPreference = 'Stop';


$package_name = 'faststone-image-viewer'
$tools_dir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://www.faststonesoft.net/DN/FSViewerSetup82.exe'
$checksum32 = 'EAC3D39FD452B3BE3ABE30077B26A6543F1769AAE7F99AA3C13190A232C354E1'

$packageArgs = @{
  packageName   = $package_name
  unzipLocation = $tools_dir
  fileType      = 'EXE'
  url           = $url
  silentArgs    = "/S"
  validExitCodes= @(0)

  softwareName  = 'FastStone Image Viewer'

  checksum      = $checksum32
  checksumType  = 'sha256'
  

}

Install-ChocolateyPackage @packageArgs









