# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Chocolatey packages repository containing community-maintained Windows software packages. The repository follows a standard Chocolatey package structure with automation tools for package management.

## Key Commands

### Package Management Commands

#### Update a Package
```powershell
# Using the general update script
.\tools\update-package.ps1 -package_name "faststone-image-viewer" -new_version "8.0.0" -new_url "https://example.com/installer.exe"

# Using AU (Automatic Updater) for packages that support it
cd packages\faststone-image-viewer
.\update.ps1
```

#### Test Packages Locally
```powershell
cd packages\faststone-image-viewer
choco pack
choco install faststone-image-viewer -s . --force
```

#### Push Package to Chocolatey Community Repository
```powershell
# Push latest package version
.\tools\push-package.ps1 -package_name "faststone-image-viewer"

# Push specific package version
.\tools\push-package.ps1 -package_name "faststone-image-viewer" -specific_nupkg "faststone-image-viewer.7.8.0.nupkg"

# Verify API key only
.\tools\push-package.ps1 -package_name "faststone-image-viewer" -verify_only
```

## Architecture and Structure

### Repository Layout
```
packages/                           # All Chocolatey packages
├── faststone-image-viewer/         # Individual package directory
│   ├── faststone-image-viewer.nuspec    # Package metadata
│   ├── update.ps1                  # AU automation script
│   ├── README.md                   # Package documentation
│   └── tools/
│       ├── chocolateyinstall.ps1   # Installation script
│       └── chocolateyuninstall.ps1 # Uninstallation script
└── template-package/               # Template for new packages
tools/                              # Repository management scripts
├── update-package.ps1              # General package update automation
└── push-package.ps1                # Package publishing automation
docs/                               # Documentation
├── package-management.md           # Detailed package management guide
└── workflow-guide.md               # Workflow documentation (gitignored)
icons/                              # Package icons for CDN hosting
```

### Package Architecture Patterns

#### Standard Package Structure
- **`.nuspec` file**: Contains package metadata, version, dependencies, and description
- **`tools/chocolateyinstall.ps1`**: Main installation script with download URL, checksum, and silent installation arguments
- **`tools/chocolateyuninstall.ps1`**: Optional uninstallation script for complex packages
- **`update.ps1`**: AU (Automatic Updater) script for packages that can be automatically updated

#### Variable Naming Conventions
All PowerShell scripts follow underscore naming conventions:
- `$package_name` for package identifier
- `$tools_dir` for tools directory path
- `$url` for download URL
- `$checksum32` for SHA256 checksum
- `$silent_args` for installer silent arguments

#### Automation Systems

##### AU (Automatic Updater) Pattern
Packages with `update.ps1` files use AU framework:
- `au_GetLatest()`: Scrapes vendor website for latest version and download URL
- `au_SearchReplace()`: Updates installation script with new URLs and checksums
- Automatically calculates checksums for downloaded files

##### Manual Update Pattern  
Uses `tools/update-package.ps1` for packages without AU automation:
- Updates `.nuspec` version and release notes
- Updates installation script variables
- Automatically downloads and calculates checksums
- Creates packed `.nupkg` file

### Security and Quality Patterns

#### Checksum Validation
All packages implement SHA256 checksum validation:
- Checksums calculated automatically during updates
- Installation fails if checksum mismatch detected
- Prevents tampering and ensures file integrity

#### API Key Management
The `push-package.ps1` script implements secure API key storage:
- API keys encrypted using PowerShell's `ConvertFrom-SecureString`
- Keys stored in `~/.chocolatey/api_key.txt`
- Masked key display for verification

## Development Workflow

### Adding New Packages
1. Copy `packages/template-package` structure
2. Rename directory and `.nuspec` file to match package ID
3. Update metadata in `.nuspec` file
4. Configure `chocolateyinstall.ps1` with download URL and silent args
5. Test installation locally with `choco install -s .`
6. Add AU automation if possible

### Package Update Process
1. Use AU script (`.\update.ps1`) if available
2. Otherwise use general script: `.\tools\update-package.ps1`
3. Test updated package locally
4. Commit changes to git
5. Push to Chocolatey community using `.\tools\push-package.ps1`

### Quality Standards
- All packages must include SHA256 checksums
- Silent installation arguments required (`/S`, `/SILENT`, etc.)
- Package IDs use lowercase with hyphens
- PowerShell variables use underscore naming
- Release notes updated automatically with version changes

## Current Packages

### faststone-image-viewer
- **Description**: FastStone Image Viewer - fast, stable image browser and editor
- **Update Method**: AU automation via `update.ps1`
- **Source**: Scrapes version from FastStone website
- **Current Version**: 7.8.0.20250428
- **Special Notes**: Uses custom AU script that parses HTML to extract version numbers