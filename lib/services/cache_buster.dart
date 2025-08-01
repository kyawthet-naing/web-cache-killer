import 'dart:io';
import 'package:path/path.dart' as path;

import '../src/config.dart';
import '../utils/logger.dart';

/// Service for applying timestamp-based cache busting to built files
class CacheBuster {
  final Config config;
  final Logger _logger;

  CacheBuster(this.config) : _logger = Logger(config.verbose);

  /// Apply timestamp to JavaScript files and update references
  /// Note: Always uses milliseconds format
  Future<bool> applyTimestampToFiles(String timestamp) async {
    _logger.printStep('🕒 Applying cache busting...');

    final buildWebPath = path.join(config.buildDir, config.webDir);
    final webDir = Directory(buildWebPath);

    if (!webDir.existsSync()) {
      _logger.printError('Build web directory not found: $buildWebPath');
      return false;
    }

    // Change to build/web directory
    final originalDir = Directory.current;
    Directory.current = webDir;

    try {
      // Find all JavaScript files to rename
      final renamedFiles = <String, String>{};
      var filesRenamed = 0;

      // Scan for actual JavaScript files
      final jsFilesToRename = await _findJavaScriptFiles();
      
      if (jsFilesToRename.isEmpty) {
        _logger.printWarning('No JavaScript files found to rename');
        return true;
      }

      for (final fileName in jsFilesToRename) {
        final file = File(fileName);
        if (file.existsSync()) {
          final newName = _generateTimestampedName(fileName, timestamp);
          await file.rename(newName);
          renamedFiles[fileName] = newName;
          if (config.verbose) {
            _logger.printSuccess('Renamed: $fileName → $newName');
          }
          filesRenamed++;
        }
      }

      // Update file references
      await _updateFileReferences(renamedFiles);

      // Verify updates only in verbose mode
      if (config.verbose) {
        await _verifyUpdates(renamedFiles);
      }

      _logger.printSuccess('Cache busting applied ($filesRenamed files)');
      return true;
    } finally {
      // Return to original directory
      Directory.current = originalDir;
    }
  }

  /// Find all JavaScript files that should be renamed
  Future<List<String>> _findJavaScriptFiles() async {
    final filesToRename = <String>[];
    
    // Find ALL .js files in the directory
    await for (final entity in Directory.current.list()) {
      if (entity is File && entity.path.endsWith('.js')) {
        final fileName = path.basename(entity.path);
        
        // Skip service worker (like the shell script)
        if (fileName == 'flutter_service_worker.js') {
          if (config.verbose) {
            _logger.printInfo('Skipping service worker: $fileName');
          }
          continue;
        }
        
        // Skip if it's already timestamped (has pattern: _YYYYMMDD_HHMMSS_mmm)
        if (fileName.contains(RegExp(r'_\d{8}_\d{6}_\d{3}'))) {
          if (config.verbose) {
            _logger.printInfo('Skipping already timestamped file: $fileName');
          }
          continue;
        }
        
        filesToRename.add(fileName);
      }
    }
    
    if (config.verbose) {
      _logger.printInfo('Found JS files: ${filesToRename.join(', ')}');
      _logger.printInfo('Files to rename: ${filesToRename.join(', ')}');
    }
    
    return filesToRename;
  }

  String _generateTimestampedName(String fileName, String timestamp) {
    final extension = path.extension(fileName);
    final nameWithoutExtension = path.basenameWithoutExtension(fileName);

    // Handle special case for main.dart.js
    if (fileName == 'main.dart.js') {
      return 'main_$timestamp.dart.js';
    }

    return '${nameWithoutExtension}_$timestamp$extension';
  }

  Future<void> _updateFileReferences(Map<String, String> renamedFiles) async {
    if (config.verbose) {
      _logger.printStep('🔍 Updating file references...');
    }

    // Find all files that might contain references (like shell script approach)
    final filesToUpdate = <String>[];
    
    // Add known files first
    const knownFiles = [
      'index.html',
      'flutter_service_worker.js', 
      'manifest.json',
      'version.json',
    ];
    
    for (final fileName in knownFiles) {
      final file = File(fileName);
      if (file.existsSync()) {
        filesToUpdate.add(fileName);
      }
    }
    
    // Add ALL other files including the renamed JS files (like shell script)
    await for (final entity in Directory.current.list()) {
      if (entity is File) {
        final fileName = path.basename(entity.path);
        final extension = path.extension(fileName).toLowerCase();
        
        // Include text-based files that might contain references
        const textExtensions = {'.js', '.map', '.json', '.html', '.css', '.txt'};
        
        if (textExtensions.contains(extension) && !filesToUpdate.contains(fileName)) {
          // Include ALL files, even the renamed ones (they may reference each other)
          filesToUpdate.add(fileName);
        }
      }
    }

    var totalUpdates = 0;

    for (final fileName in filesToUpdate) {
      final file = File(fileName);
      if (!file.existsSync()) continue;

      try {
        var content = await file.readAsString();
        var fileUpdated = false;

        // Update each renamed file reference (like shell script - multiple patterns)
        for (final entry in renamedFiles.entries) {
          final oldName = entry.key;
          final newName = entry.value;

          // Check if file contains the old reference first
          if (content.contains(oldName)) {
            // Apply multiple replacement patterns (like shell script)
            final originalContent = content;
            
            // Basic replacement
            content = content.replaceAll(oldName, newName);
            
            // Quoted replacements
            content = content.replaceAll('"$oldName"', '"$newName"');
            content = content.replaceAll("'$oldName'", "'$newName'");
            
            // URL-style replacements
            content = content.replaceAll('/$oldName', '/$newName');
            content = content.replaceAll('./$oldName', './$newName');
            
            if (content != originalContent) {
              fileUpdated = true;
            }
          }
        }

        if (fileUpdated) {
          await file.writeAsString(content);
          if (config.verbose) {
            _logger.printSuccess('Updated references in $fileName');
          }
          totalUpdates++;
        }
      } catch (e) {
        if (config.verbose) {
          _logger.printWarning('Could not update $fileName: $e');
        }
      }
    }

    if (config.verbose) {
      _logger.printInfo('Total files updated: $totalUpdates');
    }
  }

  Future<void> _verifyUpdates(Map<String, String> renamedFiles) async {
    _logger.printStep('🔍 Verifying reference updates...');

    // Check for remaining old references (like shell script)
    var foundOldRefs = false;

    for (final entry in renamedFiles.entries) {
      final oldName = entry.key;
      final newName = entry.value;
      
      // Look for old references in all files (excluding the new timestamped files)
      var remainingRefs = <String>[];
      
      await for (final entity in Directory.current.list()) {
        if (entity is File) {
          final fileName = path.basename(entity.path);
          
          // Skip binary files and the new timestamped files
          if (_isBinaryFile(fileName) || fileName.contains('_${_extractTimestamp(newName)}')) {
            continue;
          }

          try {
            final content = await entity.readAsString();
            if (content.contains(oldName)) {
              remainingRefs.add('$fileName contains reference to $oldName');
            }
          } catch (e) {
            // Skip files that can't be read as text
            continue;
          }
        }
      }
      
      if (remainingRefs.isNotEmpty) {
        if (!foundOldRefs) {
          _logger.printWarning('Found remaining old references:');
          foundOldRefs = true;
        }
        for (final ref in remainingRefs) {
          print('  ⚠️  $ref');
        }
      }
    }

    if (!foundOldRefs) {
      _logger.printSuccess('All references successfully updated!');
    }

    // Show updated index.html content (like shell script)
    final indexFile = File('index.html');
    if (indexFile.existsSync()) {
      try {
        final content = await indexFile.readAsString();
        final lines = content.split('\n');
        
        _logger.printInfo('Updated script tags in index.html:');
        for (var i = 0; i < lines.length; i++) {
          final line = lines[i];
          if (line.contains('src=') && line.contains('.js')) {
            print('${i + 1}:  ${line.trim()}');
            // Only show first few lines
            if (i > 30) break;
          }
        }
      } catch (e) {
        // Ignore errors reading index.html
      }
    }
  }

  /// Extract timestamp from timestamped filename
  String _extractTimestamp(String timestampedName) {
    final match = RegExp(r'_(\d{8}_\d{6}_\d{3})').firstMatch(timestampedName);
    return match?.group(1) ?? '';
  }

  bool _isBinaryFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    const binaryExtensions = {
      '.png',
      '.jpg',
      '.jpeg',
      '.gif',
      '.ico',
      '.wasm',
      '.ttf',
      '.otf',
      '.woff',
      '.woff2'
    };
    return binaryExtensions.contains(extension);
  }
}