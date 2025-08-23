$ErrorActionPreference = 'Stop';


$package_name = 'faststone-image-viewer'
$tools_dir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://www.faststonesoft.net/DN/FSViewerSetup81.exe'
$checksum32 = 'F4F804B3B645F3510BA29D57EE3E26FD7A032022F54C39ECEAEE42B4F4072113'

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









