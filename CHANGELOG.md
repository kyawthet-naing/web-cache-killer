# Changelog

## 0.0.2 - 2025-01-08

### Fixed
- **BREAKING FIX**: Removed Flutter SDK dependencies to enable global activation
- Fixed "requires the Flutter SDK, which is unsupported for global executables" error
- Replaced `flutter_test` with pure Dart `test` package
- Replaced `flutter_lints` with pure Dart `lints` package
- Updated analysis_options.yaml to use Dart lints instead of Flutter lints

### Changed
- Package is now a pure Dart CLI tool (no Flutter SDK required)
- Can be globally activated with `dart pub global activate web_cache_killer`
- Works on all platforms (Windows, macOS, Linux) without Flutter SDK dependency issues

### Migration
- No code changes needed for users
- Simply reactivate globally: `dart pub global activate web_cache_killer`

## 0.0.1 - Initial Release

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