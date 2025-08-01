import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:archive/archive_io.dart';

import 'config.dart';
import '../services/build_service.dart';
import '../services/cache_buster.dart';
import '../services/upload_service.dart';
import '../utils/logger.dart';
import '../utils/file_utils.dart';

/// Main deployer class that orchestrates the build and deploy process
class Builder {
  final Config config;
  final Logger _logger;
  final BuildService _buildService;
  final CacheBuster _cacheBuster;
  final UploadService _uploadService;
  final FileUtils _fileUtils;

  Builder(this.config)
      : _logger = Logger(config.verbose),
        _buildService = BuildService(config),
        _cacheBuster = CacheBuster(config),
        _uploadService = UploadService(config),
        _fileUtils = FileUtils();

  /// Main deployment process
  Future<bool> deploy() async {
    try {
      _logger.printHeader('Web Cache Killer');

      // Pre-flight checks
      if (!await _checkRequirements()) {
        return false;
      }

      // Build process
      if (!await _buildProcess()) {
        return false;
      }

      // Cache busting (always milliseconds)
      final timestamp = _generateTimestamp();
      if (!await _cacheBuster.applyTimestampToFiles(timestamp)) {
        return false;
      }

      // Package (if not skipped)
      String uploadResult = 'skipped_no_zip';
      if (!config.noZip) {
        if (!await _packageBuild()) {
          return false;
        }

        // Upload (based on configuration)
        uploadResult = await _handleUpload();
      } else {
        _logger.printInfo('Zip creation skipped');
      }

      // Show summary
      _showSummary(timestamp, uploadResult);

      return true;
    } catch (e) {
      _logger.printError('Deployment failed: $e');
      return false;
    }
  }

  Future<bool> _checkRequirements() async {
    _logger.printStep('Checking requirements...');

    // Check if in Flutter project
    if (!File('pubspec.yaml').existsSync()) {
      _logger.printError(
          'pubspec.yaml not found. Run this from your Flutter project root.');
      return false;
    }

    // Check Flutter installation
    try {
      final flutterResult = await Process.run('flutter', ['--version']);
      if (flutterResult.exitCode != 0) {
        _logger.printError('Flutter is not installed or not in PATH');
        return false;
      }
    } catch (e) {
      _logger.printError('Flutter is not installed or not in PATH: $e');
      return false;
    }

    _logger.printSuccess('Requirements satisfied');
    return true;
  }

  Future<bool> _buildProcess() async {
    if (config.clean) {
      if (!await _buildService.clean()) return false;
    }

    if (!await _buildService.getDependencies()) return false;
    if (!await _buildService.buildWeb()) return false;

    // If using custom name, rename the web directory
    if (config.webDir != 'web') {
      await _renameWebDirectory();
    }

    return true;
  }

  /// Rename the default web directory to custom name
  Future<void> _renameWebDirectory() async {
    final defaultWebPath = path.join(config.buildDir, 'web');
    final customWebPath = path.join(config.buildDir, config.webDir);

    final defaultDir = Directory(defaultWebPath);
    final customDir = Directory(customWebPath);

    if (defaultDir.existsSync()) {
      // Remove existing custom directory if it exists
      if (customDir.existsSync()) {
        await customDir.delete(recursive: true);
      }

      // Rename web to custom name
      await defaultDir.rename(customWebPath);

      if (config.verbose) {
        _logger.printInfo('Renamed web directory to: ${config.webDir}');
      }
    }
  }

  /// Generate timestamp in milliseconds format only
  String _generateTimestamp() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}_'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}_'
        '${now.millisecond.toString().padLeft(3, '0')}';
  }

  Future<bool> _packageBuild() async {
    _logger.printStep('Creating deployment package...');

    final sourceDir = path.join(config.buildDir, config.webDir);
    final zipPath = path.join(config.buildDir, config.zipName);

    try {
      // Check if source directory exists
      final webDirectory = Directory(sourceDir);
      if (!webDirectory.existsSync()) {
        _logger.printError('Web build directory not found: $sourceDir');
        return false;
      }

      // Remove existing zip
      final zipFile = File(zipPath);
      if (zipFile.existsSync()) {
        _logger.printInfo('Removing existing ${config.zipName}');
        zipFile.deleteSync();
      }

      // Create zip using archive package (cross-platform)
      await _createZipFile(sourceDir, zipPath);

      final size = await _fileUtils.getFileSize(zipPath);
      _logger
          .printSuccess('Successfully created ${config.zipName} (Size: $size)');

      return true;
    } catch (e) {
      _logger.printError('Failed to create ${config.zipName}: $e');
      return false;
    }
  }

  /// Creates a zip file using the archive package (cross-platform)
  Future<void> _createZipFile(String sourceDir, String zipPath) async {
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);

    final directory = Directory(sourceDir);

    // Add all files and subdirectories
    await _addDirectoryToZip(encoder, directory, sourceDir);

    await encoder.close();
  }

  /// Recursively adds directory contents to zip
  Future<void> _addDirectoryToZip(
      ZipFileEncoder encoder, Directory dir, String basePath) async {
    await for (final entity in dir.list(recursive: false)) {
      final relativePath = path.relative(entity.path, from: basePath);

      if (entity is File) {
        await encoder.addFile(entity, relativePath);
      } else if (entity is Directory) {
        // Recursively add subdirectory contents
        await _addDirectoryToZip(encoder, entity, basePath);
      }
    }
  }

  /// Handle upload - NO CONFIRMATION PROMPTS
  Future<String> _handleUpload() async {
    // If autoUpload is true, upload automatically
    if (config.autoUpload) {
      _logger.printStep('Uploading to tmpfiles.org...');
      final success = await _uploadService.upload();
      return success ? 'success' : 'failed';
    }

    // Fallback (shouldn't happen with current logic)
    final zipPath = path.join(config.buildDir, config.zipName);
    _logger.printInfo('Build completed. Package available at: $zipPath');
    return 'skipped_no_upload';
  }

  void _showSummary(String timestamp, String uploadResult) {
    print('');
    print('==================================');
    _logger.printSuccess('🎉 Build Completed!');
    print('');

    // Only show zip status if not skipped
    if (!config.noZip) {
      print('✅ Created: ${config.zipName}');
    }

    switch (uploadResult) {
      case 'success':
        print('✅ Uploaded successfully');
        break;
      case 'skipped_build_only':
        final zipPath =
            path.join(Directory.current.path, config.buildDir, config.zipName);
        print('📁 Local: $zipPath');
        break;
      case 'skipped_no_zip':
        final buildPath =
            path.join(Directory.current.path, config.buildDir, config.webDir);
        print('📁 Build: $buildPath');
        break;
      case 'failed':
        print('❌ Upload failed');
        final zipPath =
            path.join(Directory.current.path, config.buildDir, config.zipName);
        print('📁 Local: $zipPath');
        break;
    }
  }
}
