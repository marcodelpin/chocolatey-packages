# Chocolatey Packages

This repository contains a collection of Chocolatey packages that I maintain and keep updated.

## Available Packages

| Package Name | Description | Version |
|-------------|-------------|---------|
| faststone-image-viewer | FastStone Image Viewer - Image viewer and editor | 7.8.0.20250428 |

## How to Use These Packages

There are several ways to install packages from this repository:

### Installation from Local Clone of the Repository

```powershell
# Clone the repository
git clone https://github.com/marcodelpin/chocolatey-packages.git
cd chocolatey-packages

# Install a package by specifying the local path
choco install faststone-image-viewer -s .\packages\faststone-image-viewer
```

### Direct Installation from GitHub Pages (if configured)

```powershell
# Example of installation from GitHub Pages
choco install faststone-image-viewer -s https://marcodelpin.github.io/chocolatey-packages/
```

### Installation from Custom Chocolatey Feed (if you have one)

```powershell
# Add your repository as a source once
choco source add -n=chocolatey-community -s="https://myget.org/F/chocolatey-community/api/v2" --priority=1

# Install the package
choco install faststone-image-viewer
```

## Requesting Package Updates

If you notice a package that needs updating, please open an issue with:

1. The name of the package
2. The new version number
3. Any changes to installation procedures (if known)

## Repository Structure

```
packages/                      # Contains all Chocolatey packages
  ├── faststone-image-viewer/  # FastStone Image Viewer package folder
  │   └── faststone-image-viewer.nuspec  # Package with the new ID
  └── other-packages/
tools/                         # Utility scripts for package management
docs/                          # Documentation
```

## Updating a Package

There are two ways to update packages:

1. Using the general script:
   ```powershell
   .\tools\update-package.ps1 -package_name "package-name" -new_version "x.y.z" -new_url "download-url"
   ```

2. For packages with AU scripts (like faststone-image-viewer):
   ```powershell
   cd packages\package-name
   .\update.ps1
   ```

## Contributing

Contributions are welcome! Please read the guidelines in [CONTRIBUTING.md](CONTRIBUTING.md) before submitting pull requests.