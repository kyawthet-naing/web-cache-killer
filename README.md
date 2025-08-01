# Web Cache Killer

Fixes Flutter web cache problems by automatically renaming JavaScript files with timestamps.

## Why You Need This

When you deploy a Flutter web app, users often see the old version because browsers cache JavaScript files. This tool fixes that by renaming your JS files with timestamps so users always get the latest version.

## Installation

```bash
dart pub global activate web_cache_killer
```

## Quick Start

```bash
# Go to your Flutter project folder
cd my_flutter_project

# Build and create web.zip
web_cache_killer

# Build with custom name (creates beta.zip)
web_cache_killer --name beta

# Build and upload automatically
web_cache_killer --auto-upload
```

## What It Does

**Before:**
```
flutter.js
main.dart.js
```

**After:**
```
flutter_20250801_143022_456.js
main_20250801_143022_456.dart.js
```

All HTML files are automatically updated to use the new names.

## Commands

| Command | What It Does |
|---------|-------------|
| `web_cache_killer` | Build and create `web.zip` |
| `web_cache_killer --name release` | Build and create `release.zip` |
| `web_cache_killer --auto-upload` | Build and upload to tmpfiles.org |
| `web_cache_killer --no-zip` | Build only (no zip file) |
| `web_cache_killer --verbose` | Show detailed output |
| `web_cache_killer --no-clean` | Skip flutter clean (faster) |

## Output Example

```
🚀 Web Cache Killer
==================================
Checking requirements...
✅ Requirements satisfied
🧹 Cleaning...
✅ Cleaned
📦 Getting dependencies...
✅ Dependencies ready
🔧 Building web...
✅ Build completed
🕒 Applying cache busting...
✅ Cache busting applied (3 files)
📦 Creating deployment package...
✅ Successfully created web.zip (Size: 7.9M)

==================================
🎉 Build Completed!
✅ Created: web.zip
📁 Build: /path/to/project/build/web
```

## File Structure

**Default build:**
```
build/
├── web/           # Your app files
└── web.zip        # Ready to deploy
```

**Custom name build:**
```
build/
├── release/         # Your app files
└── release.zip      # Ready to deploy
```

## Upload Feature

Upload your zip automatically to get a direct download link:

```bash
web_cache_killer --auto-upload
```

You'll get a link like: `http://tmpfiles.org/dl/123456/web.zip`

## Common Issues

**❌ "pubspec.yaml not found"**
- Make sure you're in your Flutter project folder

**❌ "Flutter not found"**
- Install Flutter: https://flutter.dev/docs/get-started/install
- Make sure `flutter` command works in your terminal

**❌ Upload fails**
- Check your internet connection
- Your zip file is still saved locally in the `build/` folder

## Requirements

- Flutter SDK installed
- Dart 2.12+ 
- Run from Flutter project root (where `pubspec.yaml` is)

## Features

✅ **Cross-platform** - Windows, macOS, Linux  
✅ **Zero setup** - Just install and run  
✅ **Cache busting** - Automatic timestamp renaming  
✅ **Custom names** - Name your builds  
✅ **Auto upload** - Get instant download links  
✅ **Fast builds** - Skip clean with `--no-clean`