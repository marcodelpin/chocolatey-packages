$ErrorActionPreference = 'Stop';


$package_name = 'faststone-image-viewer'
$tools_dir   = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://www.faststonesoft.net/DN/FSViewerSetup80.exe'
$checksum32 = 'f2e91e0d4999ee1772afb0986df1ecc825cb84b776536b7ed9ea3372dab551de'

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








