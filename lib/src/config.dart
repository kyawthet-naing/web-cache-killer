/// Configuration class for Web Builder
class Config {
  /// Whether to upload automatically without confirmation
  final bool autoUpload;

  /// Whether to skip zip creation entirely
  final bool noZip;

  /// Timestamp format for cache busting (fixed to milliseconds)
  final String timestampFormat;

  /// Whether to run flutter clean before building
  final bool clean;

  /// Whether to show verbose output
  final bool verbose;

  /// Build directory name
  final String buildDir;

  /// Web directory name within build
  final String webDir;

  /// Zip file name (customizable)
  final String zipName;

  const Config({
    this.autoUpload = false,
    this.noZip = false,
    this.timestampFormat = 'milliseconds', // Fixed to milliseconds only
    this.clean = true,
    this.verbose = false,
    this.buildDir = 'build',
    this.webDir = 'web',
    this.zipName = 'web.zip',
  });

  /// Upload services configuration
  static const Map<String, String> uploadUrls = {
    'tmpfiles': 'https://tmpfiles.org/api/v1/upload',
  };

  /// JavaScript files to exclude from renaming
  static const List<String> jsFilesToExclude = [
    'flutter_service_worker.js', // Don't rename service worker
  ];

  /// Files that may contain references to JS files
  static const List<String> filesToUpdate = [
    'index.html',
    'flutter_service_worker.js',
    'manifest.json',
    'version.json',
  ];
}
