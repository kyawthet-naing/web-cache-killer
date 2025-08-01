import 'dart:io';
import 'package:path/path.dart' as path;

import '../src/config.dart';
import '../utils/logger.dart';

/// Service for handling Flutter build operations
class BuildService {
  final Config config;
  final Logger _logger;

  BuildService(this.config) : _logger = Logger(config.verbose);

  /// Run flutter clean
  Future<bool> clean() async {
    _logger.printStep('🧹 Cleaning...');

    final result = await Process.run('flutter', ['clean']);

    if (result.exitCode != 0) {
      _logger.printError('Flutter clean failed');
      if (config.verbose) {
        _logger.printError('Error: ${result.stderr}');
      }
      return false;
    }

    _logger.printSuccess('Cleaned');
    return true;
  }

  /// Run flutter pub get
  Future<bool> getDependencies() async {
    _logger.printStep('📦 Getting dependencies...');

    final result = await Process.run('flutter', ['pub', 'get']);

    if (result.exitCode != 0) {
      _logger.printError('Failed to get dependencies');
      if (config.verbose) {
        _logger.printError('Error: ${result.stderr}');
      }
      return false;
    }

    _logger.printSuccess('Dependencies ready');
    return true;
  }

  /// Build Flutter web app
  Future<bool> buildWeb() async {
    _logger.printStep('🔧 Building web...');

    final result = await Process.run('flutter', ['build', 'web', '--release']);

    if (result.exitCode != 0) {
      _logger.printError('Flutter web build failed');
      if (config.verbose) {
        _logger.printError('Error: ${result.stderr}');
      }
      return false;
    }

    // Verify build output exists (always check for 'web' first, then custom name)
    final defaultBuildPath = path.join(config.buildDir, 'web');
    if (!Directory(defaultBuildPath).existsSync()) {
      _logger.printError('Build failed - $defaultBuildPath not found');
      return false;
    }

    _logger.printSuccess('Build completed');
    return true;
  }

  /// Check if build directory exists and has required files
  bool validateBuild() {
    final buildWebPath = path.join(config.buildDir, config.webDir);
    final indexFile = File(path.join(buildWebPath, 'index.html'));

    return Directory(buildWebPath).existsSync() && indexFile.existsSync();
  }
}
