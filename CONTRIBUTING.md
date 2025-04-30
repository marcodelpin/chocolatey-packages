# Contributing Guidelines

Thank you for your interest in contributing to this Chocolatey packages repository. Below are some guidelines to help you get started.

## Adding a New Package

1. Create a new folder under `packages/` with the name of your package (lowercase).
2. Inside that folder, add the following files:
   - `<package_name>.nuspec` - The package metadata
   - `tools/chocolateyInstall.ps1` - Installation script
   - `tools/chocolateyUninstall.ps1` - (Optional) Uninstallation script
   - `README.md` - Package-specific documentation
   - `update.ps1` - (Recommended) Script for automatic updating (AU)

## Package Structure Example

```
packages/
└── fsviewer/
    ├── fsviewer.nuspec
    ├── README.md
    ├── update.ps1
    └── tools/
        ├── chocolateyInstall.ps1
        └── chocolateyUninstall.ps1
```

## Naming Conventions

- Use underscores for field names in scripts and configuration files.
- Keep package names lowercase.
- Use descriptive variable names.
- Use consistent underscore style, for example:
  ```powershell
  $package_name    = 'fsviewer'
  $tools_dir       = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
  $url             = 'https://www.faststonesoft.net/DN/FSViewerSetup80.exe'
  $checksum        = 'f2e91e0d4999ee1772afb0986df1ecc825cb84b776536b7ed9ea3372dab551de'
  $checksum_type   = 'sha256'
  $silent_args     = '/S'
  ```

## Testing Packages

Before submitting, test your package locally:

```powershell
cd packages/fsviewer
choco pack
choco install fsviewer -s . --force
```

## Updating Packages

There are two methods for updating packages:

### 1. Using AU (recommended for packages that can be updated automatically)

Create or modify the `update.ps1` script as follows:

```powershell
import-module au

function global:au_GetLatest {
    $latest_release_url = 'https://www.faststone.org/FSIVDownload.htm'
    $latest_release = Invoke-WebRequest $latest_release_url
    $url = $latest_release.Links | ? href -match '\.exe' | % href | Select-Object -first 1
    $Searchtext ='<font face="Verdana" size="2">FastStone Image Viewer '
    [string]$latestrelstr = $latest_release
    $index = $latestrelstr.IndexOf($Searchtext)
    $Version = $latestrelstr.Substring($index + $Searchtext.Length, 3)
    
    return @{
        URL32 = $url
        Version = $Version
    }
}

function global:au_SearchReplace {
    @{
        'tools\chocolateyInstall.ps1' = @{
            "(^[$]url\s*=\s*)('.*')"      = "`$1'$($Latest.URL32)'"
            "(^[$]checksum32\s*=\s*)('.*')" = "`$1'$($Latest.Checksum32)'"
        }
    }
}

update
```

Run the script with:
```powershell
cd packages\fsviewer
.\update.ps1
```

### 2. Using the provided general script

```powershell
.\tools\update-package.ps1 -package_name "fsviewer" -new_version "8.0.0" -new_url "https://www.faststonesoft.net/DN/FSViewerSetup80.exe"
```

## Submitting Changes

1. Fork the repository from https://github.com/marcodelpin/chocolatey-packages.
2. Create a new branch with a descriptive name.
3. Make your changes.
4. Test your changes locally.
5. Submit a pull request with a clear description of the changes.

Thank you for your contribution!