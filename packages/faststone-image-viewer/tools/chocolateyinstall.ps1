$ErrorActionPreference = 'Stop';


$package_name = 'faststone-image-viewer'
$tools_dir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://www.faststonesoft.net/DN/FSViewerSetup83.exe'
$checksum32 = '5978cb9401efde53b494b799fe82fadf71b86f4603dec7ee0bf6647ac0e45bc3'

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









