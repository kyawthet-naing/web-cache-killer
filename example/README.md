# Examples

You can also find more general documentation in the main [README.md](../README.md).

## Install
```bash
dart pub global activate web_cache_killer
```

## Basic Commands
```bash
web_cache_killer                    # Creates web.zip
web_cache_killer --name release     # Creates release.zip  
web_cache_killer --auto-upload      # Build and upload
web_cache_killer --no-zip           # Build folder only
```

## Common Use Cases
```bash
# Quick deploy
web_cache_killer --auto-upload

# Development (faster)
web_cache_killer --no-clean

# Production build
web_cache_killer --name prod --auto-upload

# See details
web_cache_killer --verbose
```

## Options
- `--name release` → Creates `release.zip`
- `--auto-upload` → Uploads and gives download link
- `--no-zip` → Creates folder only (no zip)
- `--no-clean` → Faster build (skips cleanup)
- `--verbose` → Shows detailed output