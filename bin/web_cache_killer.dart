import 'dart:io';
import 'package:args/args.dart';
import 'package:web_cache_killer/web_cache_killer.dart';

Future<void> main(List<String> arguments) async {
  Logger logger = Logger(false);
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Show this help message',
      negatable: false,
    )
    ..addFlag(
      'version',
      abbr: 'v',
      help: 'Show version information',
      negatable: false,
    )
    ..addFlag(
      'auto-upload',
      help: 'Upload automatically without confirmation',
      defaultsTo: false,
    )
    ..addFlag(
      'no-zip',
      help: 'Skip zip creation (build only)',
      defaultsTo: false,
    )
    ..addOption(
      'name',
      help: 'Custom name for zip file (without .zip extension)',
      defaultsTo: 'web',
    )
    ..addFlag(
      'clean',
      help: 'Run flutter clean before building',
      defaultsTo: true,
    )
    ..addFlag(
      'verbose',
      help: 'Show verbose output',
      defaultsTo: false,
    );

  try {
    final results = parser.parse(arguments);

    // Show help
    if (results['help'] as bool) {
      _showHelp(parser);
      return;
    }

    // Show version
    if (results['version'] as bool) {
      _showVersion();
      return;
    }

    final autoUpload = results['auto-upload'] as bool;
    final noZip = results['no-zip'] as bool;
    final customName = results['name'] as String;

    // Validate conflicting options
    if (noZip && autoUpload) {
      logger.printError('Error: Cannot use --auto-upload with --no-zip');
      exit(1);
    }

    // Create configuration
    final config = Config(
      autoUpload: autoUpload,
      noZip: noZip,
      zipName: '$customName.zip',
      webDir: customName, // Use custom name for web directory too
      timestampFormat: 'milliseconds', // Fixed to milliseconds only
      clean: results['clean'] as bool,
      verbose: results['verbose'] as bool,
    );

    // Run the deployment
    final deployer = Builder(config);
    final success = await deployer.deploy();

    exit(success ? 0 : 1);
  } catch (e) {
    logger.printError('Error: $e');
    print('');
    _showHelp(parser);
    exit(1);
  }
}

void _showHelp(ArgParser parser) {
  print('Web Cache Killer - Build, cache-bust & deploy Flutter web apps');
  print('');
  print('Usage: web_cache_killer [options]');
  print('');
  print('Options:');
  print(parser.usage);
  print('');
  print('Examples:');
  print(
      '  web_cache_killer                    # Build to build/web/ and create web.zip');
  print(
      '  web_cache_killer --auto-upload      # Build and upload web.zip automatically');
  print(
      '  web_cache_killer --no-zip           # Build to build/web/ only (no zip)');
  print(
      '  web_cache_killer --name app         # Build to build/app/ and create app.zip');
  print(
      '  web_cache_killer --name hello --auto-upload  # Build to build/hello/ and upload hello.zip');
  print('  web_cache_killer --verbose          # Show detailed output');
  print('  web_cache_killer --no-clean         # Skip flutter clean step');
  print('');
  print('Note: --name changes both the folder name and zip name');
  print('      Timestamps are automatically set to milliseconds format.');
}

void _showVersion() {
  print('Web Cache Killer v0.0.3');
  print(
      'A CLI tool for building and deploying Flutter web apps with cache busting.');
}
