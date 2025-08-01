# Changelog

## 0.0.3 - 2025-08-01

### What's Fixed
- **Custom names now work!** - Fixed `--name hello` creating proper folders and zip files
- **Better error messages** - Shows clear info when something goes wrong
- **Cleaner output** - Less clutter, more helpful messages

### What Changed
- Custom builds like `--name app` now create `build/app/` and `app.zip` correctly
- Added progress indicators so you know what's happening
- Fixed internal build process order

## 0.0.2 - 2025-01-08

### What's Fixed
- **Made it work globally** - Can now install with `dart pub global activate`
- Fixed "Flutter SDK required" error
- Works on all computers (Windows, Mac, Linux)

### What Changed
- Now a pure Dart tool (no Flutter SDK dependency issues)
- Easier to install and use

## 0.0.1 - 2025-01-01

### First Release
- Fixes Flutter web cache problems
- Renames JavaScript files with timestamps
- Creates zip files ready to deploy
- Upload feature to get instant download links

### Commands
```bash
web_cache_killer                 # Build and create web.zip
web_cache_killer --name app      # Build and create app.zip
web_cache_killer --auto-upload   # Build and upload automatically
```