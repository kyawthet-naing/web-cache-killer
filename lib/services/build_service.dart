import 'dart:io';
import 'package:path/path.dart' as path;

import '../src/config.dart';
import '../utils/logger.dart';

/// Build service with dynamic Flutter detection
class BuildService {
  final Config config;
  final Logger _logger;
  String? _cachedFlutterPath;

  BuildService(this.config) : _logger = Logger(config.verbose);

  /// Dynamic Flutter detection
  Future<String?> _findFlutterPath() async {
    if (_cachedFlutterPath != null) return _cachedFlutterPath;

    final commands = Platform.isWindows 
        ? ['flutter', 'flutter.bat', 'flutter.exe']
        : ['flutter'];

    for (final command in commands) {
      try {
        final result = await Process.run(command, ['--version']).timeout(Duration(seconds: 5));
        if (result.exitCode == 0) {
          _cachedFlutterPath = command;
          return command;
        }
      } catch (e) {
        continue;
      }
    }

    // Check common locations
    if (Platform.isWindows) {
      final commonPaths = [
        r'C:\Windows\flutter\bin\flutter.bat',
        r'C:\flutter\bin\flutter.bat',
        r'C:\src\flutter\bin\flutter.bat',
        r'C:\tools\flutter\bin\flutter.bat',
        path.join(Platform.environment['USERPROFILE'] ?? '', 'flutter', 'bin', 'flutter.bat'),
      ];

      for (final flutterPath in commonPaths) {
        if (File(flutterPath).existsSync()) {
          try {
            final result = await Process.run(flutterPath, ['--version']).timeout(Duration(seconds: 5));
            if (result.exitCode == 0) {
              _cachedFlutterPath = flutterPath;
              return flutterPath;
            }
          } catch (e) {
            continue;
          }
        }
      }
    }

    return null;
  }

  /// Run Flutter command
  Future<ProcessResult> _runFlutterCommand(List<String> args) async {
    final flutterPath = await _findFlutterPath();
    
    if (flutterPath == null) {
      throw ProcessException('flutter', args, 'Flutter not found');
    }

    if (config.verbose) {
      _logger.printVerbose('Running: $flutterPath ${args.join(' ')}');
    }
    
    return await Process.run(flutterPath, args);
  }

  /// Check requirements
  Future<bool> checkRequirements() async {
    _logger.printStep('Checking requirements...');

    if (!File('pubspec.yaml').existsSync()) {
      _logger.printError('pubspec.yaml not found. Run from Flutter project root.');
      return false;
    }

    try {
      final flutterPath = await _findFlutterPath();
      if (flutterPath == null) {
        _logger.printError('Flutter not found on this system');
        _showFlutterHelp();
        return false;
      }

      final result = await Process.run(flutterPath, ['--version']);
      if (result.exitCode == 0) {
        _logger.printSuccess('Requirements satisfied');
        return true;
      }
    } catch (e) {
      _logger.printError('Flutter test failed: $e');
      _showFlutterHelp();
      return false;
    }

    return false;
  }

  /// Show Flutter help
  void _showFlutterHelp() {
    if (Platform.isWindows) {
      _logger.printError('Install Flutter: https://flutter.dev/docs/get-started/install/windows');
    }
  }

  /// Flutter clean
  Future<bool> clean() async {
    _logger.printStep('🧹 Cleaning...');

    try {
      final result = await _runFlutterCommand(['clean']);

      if (result.exitCode != 0) {
        _logger.printError('Flutter clean failed');
        if (config.verbose) {
          _logger.printError('Error: ${result.stderr}');
        }
        return false;
      }

      _logger.printSuccess('Cleaned');
      return true;
    } catch (e) {
      _logger.printError('Flutter clean failed: $e');
      return false;
    }
  }

  /// Flutter pub get
  Future<bool> getDependencies() async {
    _logger.printStep('📦 Getting dependencies...');

    try {
      final result = await _runFlutterCommand(['pub', 'get']);

      if (result.exitCode != 0) {
        _logger.printError('Failed to get dependencies');
        if (config.verbose) {
          _logger.printError('Error: ${result.stderr}');
        }
        return false;
      }

      _logger.printSuccess('Dependencies ready');
      return true;
    } catch (e) {
      _logger.printError('Failed to get dependencies: $e');
      return false;
    }
  }

  /// Flutter build web
  Future<bool> buildWeb() async {
    _logger.printStep('🔧 Building web...');

    try {
      final result = await _runFlutterCommand(['build', 'web', '--release']);

      if (result.exitCode != 0) {
        _logger.printError('Flutter web build failed');
        if (config.verbose) {
          _logger.printError('Error: ${result.stderr}');
        }
        return false;
      }

      // Verify build output exists
      final defaultBuildPath = path.join(config.buildDir, 'web');
      if (!Directory(defaultBuildPath).existsSync()) {
        _logger.printError('Build failed - $defaultBuildPath not found');
        return false;
      }

      _logger.printSuccess('Build completed');
      return true;
    } catch (e) {
      _logger.printError('Flutter build failed: $e');
      return false;
    }
  }

  /// Validate build output
  bool validateBuild() {
    final buildWebPath = path.join(config.buildDir, config.webDir);
    final indexFile = File(path.join(buildWebPath, 'index.html'));

    return Directory(buildWebPath).existsSync() && indexFile.existsSync();
  }
}