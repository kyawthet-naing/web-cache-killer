# Web Cache Killer

A Flutter package that solves Flutter web cache problems by automatically renaming JavaScript files with timestamps during build process.

## The Problem

Flutter web apps often face caching issues where users see old versions of your app even after deployment. Browsers cache JavaScript files aggressively, causing users to see outdated content until they manually clear their cache.

## The Solution

Web Cache Killer automatically renames your Flutter web JavaScript files with unique timestamps and updates all references, ensuring users always get the latest version of your app without manual cache clearing.

## Features

- 🔧 **Cross-platform** - Works on Windows, macOS, and Linux
- 📦 **Zero dependencies** - Uses built-in Dart archive package
- 🕒 **Cache busting** - Automatic timestamp-based cache busting
- 🚀 **Simple commands** - Easy to use CLI tool
- 📤 **Optional upload** - Upload to [tmpfiles.org](https://tmpfiles.org/) and get direct download link `http://tmpfiles.org/dl/123456/web.zip`

## Installation

```bash
dart pub global activate web_cache_killer
```

## Usage

### Basic Commands

```bash
# Build and create zip
web_cache_killer

# Custom name (creates build/app/ and app.zip)
web_cache_killer --name app

# Auto upload
web_cache_killer --auto-upload

# Build only (no zip)
web_cache_killer --no-zip
```

### Options

```bash
# Verbose output
web_cache_killer --verbose

# Skip clean step (faster)
web_cache_killer --no-clean

# Combined options
web_cache_killer --name myapp --auto-upload --verbose
```

## How It Works

Automatically renames JavaScript files with timestamps for cache busting:

**Before:**
```
flutter.js → flutter_20241201_143022_456.js
main.dart.js → main_20241201_143022_456.dart.js
```

All references in HTML files are automatically updated.

## File Structure

**Default:**
```
build/
├── web/           # Built files
└── web.zip        # Package
```

**Custom name:**
```
build/
├── app/           # Built files  
└── app.zip        # Package
```

## Expected Output

```
🚀 Web Cache Killer
==================================
Checking requirements...
✅ Requirements satisfied
🧹 Cleaning...
✅ Cleaned
🔧 Building web...
✅ Build completed
🕒 Applying cache busting...
✅ Cache busting applied (3 files)
📦 Creating deployment package...
✅ Successfully created web.zip (Size: 7.9 MB)

==================================
✅ 🎉 Build Completed!

✅ Created: web.zip
📁 Local: /path/to/project/build/web.zip
```

## Troubleshooting

- **"pubspec.yaml not found"** - Run from Flutter project root
- **"Flutter not found"** - Install Flutter SDK and add to PATH
- **Upload fails** - Check internet connection, zip still available locally