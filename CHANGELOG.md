# Changelog

## 0.0.1

### Initial Release

Solves Flutter web cache problems by automatically renaming JavaScript files with timestamps.

#### Features
- **Automatic cache busting** - Renames JS files with timestamps
- **Cross-platform** - Works on Windows, macOS, Linux
- **Simple commands** - Easy CLI interface
- **Custom naming** - `--name app` creates build/app/ and app.zip
- **Auto upload** - `--auto-upload` uploads to tmpfiles.org
- **Build only** - `--no-zip` skips zip creation
- **Zero dependencies** - Uses built-in Dart archive package

#### Commands
```bash
web_cache_killer                    # Build and create zip
web_cache_killer --name app         # Custom name
web_cache_killer --auto-upload      # Build and upload
web_cache_killer --no-zip           # Build only
web_cache_killer --verbose          # Detailed output
```

#### Cache Busting
- `flutter.js` → `flutter_20241201_143022_456.js`
- `main.dart.js` → `main_20241201_143022_456.dart.js`
- Updates all HTML references automatically

Ensures users always get the latest version without manual cache clearing.