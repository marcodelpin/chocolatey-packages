# FastStone Image Viewer (faststone-image-viewer)

[![Chocolatey](https://img.shields.io/chocolatey/v/faststone-image-viewer)](https://community.chocolatey.org/packages/faststone-image-viewer)

This is a Chocolatey package for FastStone Image Viewer, a fast, stable, and user-friendly image viewer with editing capabilities.

**Chocolatey Package:** https://community.chocolatey.org/packages/faststone-image-viewer

## Description

FastStone Image Viewer is an image viewer, browser, converter, and editor. It has a set of features that include image viewing, management, comparison, red-eye removal, emailing, resizing, cropping, retouching, and color adjustments. Its innovative yet intuitive full-screen mode provides quick access to EXIF information, thumbnail browser, and major functionalities via hidden toolbars that appear when your mouse touches one of the four edges of the screen.

## Features

- Image viewing with support for all major formats
- Image editing tools (crop, resize, adjustments)
- Support for RAW formats from digital cameras
- Full-screen mode with hidden toolbars
- Slideshows with transition effects
- EXIF information display

## Installation

```powershell
choco install faststone-image-viewer
```

## Package Updates

This package is automatically updated via AU (Automatic Updater). If you notice it's outdated, you can:

1. Run the update manually:
   ```powershell
   cd packages\fsviewer
   .\update.ps1
   ```

2. Or open an issue in the repository to report the need for an update.

## Release Notes

For complete release notes, visit: http://www.faststone.org/FSViewerDetail.htm#History

## Package Maintenance

This package follows the naming convention with underscores for field names in PowerShell scripts:

```powershell
$package_name = 'faststone-image-viewer'
```

If you modify the package, make sure to follow this convention.