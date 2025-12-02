# Chocolatey Package Management Guide

This document explains how to manage Chocolatey packages in this repository.

## Table of Contents
- [Adding a New Package](#adding-a-new-package)
- [Example Structure](#example-structure)
- [Updating Packages](#updating-packages)
- [Testing Packages](#testing-packages)
- [Publishing Packages](#publishing-packages)
- [Naming Conventions](#naming-conventions)
- [Common Field Names](#common-field-names)
- [Existing Packages](#existing-packages)

## Adding a New Package

1. Create a new folder under `packages/` with the name of your package (lowercase).
2. Copy the template structure from `packages/template-package`.
3. Update the nuspec file with your package details.
4. Update the chocolateyInstall.ps1 script with installation details.
5. Update the chocolateyUninstall.ps1 script if needed.
6. Add an update.ps1 file if you prefer automatic updates via AU.

## Example Structure

```
packages/
└── faststone-image-viewer/               # Directory renamed to match package ID
    ├── faststone-image-viewer.nuspec     # File renamed to match package ID
    ├── update.ps1
    └── tools/
        ├── chocolateyinstall.ps1
        └── chocolateyuninstall.ps1
```

## Updating Packages

There are two methods for updating packages:

### Method 1: Using the general update script

```powershell
# Basic usage
.\tools\update-package.ps1 -package_name "faststone-image-viewer" -new_version "8.0.0"

# With new URL
.\tools\update-package.ps1 -package_name "faststone-image-viewer" -new_version "8.0.0" -new_url "https://www.faststonesoft.net/DN/FSViewerSetup80.exe"

# With new URL and checksum
.\tools\update-package.ps1 -package_name "faststone-image-viewer" -new_version "8.0.0" -new_url "https://www.faststonesoft.net/DN/FSViewerSetup80.exe" -new_checksum "f2e91e0d4999ee1772afb0986df1ecc825cb84b776536b7ed9ea3372dab551de" -checksum_type "sha256"
```

The script will:
1. Update the version in the nuspec file
2. Update the version in the installation script
3. Update the URL and/or checksum if provided
4. Update the release notes
5. Pack the package

### Method 2: Using AU (Automatic Updater)

For packages with AU scripts like faststone-image-viewer:

```powershell
cd packages\faststone-image-viewer
.\update.ps1
```

## Testing Packages

Before submitting changes, test your package locally:

```powershell
cd packages/faststone-image-viewer
choco pack
choco install faststone-image-viewer -s . --force
```

## Publishing Packages

After testing, commit and push your changes to GitHub:

```powershell
git add packages/faststone-image-viewer
git commit -m "Update faststone-image-viewer to version 8.0.0"
git push
```

The GitHub Actions workflow will automatically validate your package changes.

## Naming Conventions

1. Use lowercase for package names.
2. Use hyphens (-) to separate words in package names.
3. Use underscores (_) for field names in scripts.

## Common Field Names

When creating or updating packages, use these standardized field names:

```powershell
$error_message   = "Error during installation or update"
$package_name    = "faststone-image-viewer"
$version         = "8.0.0"
$url             = "https://www.faststonesoft.net/DN/FSViewerSetup80.exe"
$checksum        = "f2e91e0d4999ee1772afb0986df1ecc825cb84b776536b7ed9ea3372dab551de"
$checksum_type   = "sha256"
$silent_args     = "/S"
$validation_type = "sha256"
```

This consistent naming helps with maintaining multiple packages and makes automation easier.

## Existing Packages

### faststone-image-viewer (FastStone Image Viewer)

FastStone Image Viewer is a fast, stable, and user-friendly image viewer with editing and conversion capabilities.

- **Current version**: 8.3
- **Chocolatey package**: https://community.chocolatey.org/packages/faststone-image-viewer
- **Update method**: Uses the custom AU script `update.ps1` which automatically extracts the version and URL from the official website.
- **Structure**: Includes nuspec, installation and uninstallation scripts, plus AU update script.

## Moderation Tracking

Track package moderation status at: https://ch0.co/moderation

| Package | Version | Submitted | Status | Notes |
|---------|---------|-----------|--------|-------|
| faststone-image-viewer | 8.3 | 2025-12-02 | ⏳ Pending | Awaiting moderation |
| faststone-image-viewer | 8.2 | 2025-11-22 | ✅ Ready | Approved |
| faststone-image-viewer | 8.1 | 2025-08-23 | ✅ Approved | Live |