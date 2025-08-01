# Examples

You can also find more general documentation in the main [README.md](../README.md).

## Installation

```bash
# Install globally
dart pub global activate web_cache_killer
```

## Quick Start

```bash
# Basic build
web_cache_killer

# Custom name
web_cache_killer --name app

# Auto upload
web_cache_killer --auto-upload

# Build only (no zip)
web_cache_killer --no-zip

# Custom name with upload
web_cache_killer --name app --auto-upload

# Verbose output
web_cache_killer --verbose

# Skip clean step
web_cache_killer --no-clean

# Development mode (fast build with details)
web_cache_killer --no-clean --verbose

# Custom name build only
web_cache_killer --name app --no-zip

# Production build
web_cache_killer --name production

# Help and version
web_cache_killer --help
web_cache_killer --version
```