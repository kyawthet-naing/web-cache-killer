import 'dart:io';
import 'dart:math';

/// File utility functions
class FileUtils {
  /// Get human-readable file size
  Future<String> getFileSize(String filePath) async {
    final file = File(filePath);
    if (!file.existsSync()) {
      return 'Unknown';
    }

    final bytes = await file.length();
    return _formatBytes(bytes);
  }

  /// Get human-readable directory size
  Future<String> getDirectorySize(String dirPath) async {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      return 'Unknown';
    }

    var totalBytes = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        try {
          totalBytes += await entity.length();
        } catch (e) {
          // Skip files that can't be read
          continue;
        }
      }
    }

    return _formatBytes(totalBytes);
  }

  /// Format bytes into human-readable string
  String _formatBytes(int bytes) {
    if (bytes == 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, i);
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Check if file exists and is readable
  bool isFileAccessible(String filePath) {
    final file = File(filePath);
    return file.existsSync() && file.statSync().mode & 0x004 != 0;
  }

  /// Check if directory exists and is accessible
  bool isDirectoryAccessible(String dirPath) {
    final dir = Directory(dirPath);
    return dir.existsSync() && dir.statSync().mode & 0x004 != 0;
  }

  /// Get file extension safely
  String getFileExtension(String filePath) {
    final lastDot = filePath.lastIndexOf('.');
    if (lastDot == -1 || lastDot == filePath.length - 1) {
      return '';
    }
    return filePath.substring(lastDot).toLowerCase();
  }

  /// Check if file is likely binary based on extension
  bool isBinaryFile(String filePath) {
    const binaryExtensions = {
      '.png', '.jpg', '.jpeg', '.gif', '.bmp', '.ico', '.svg',
      '.wasm', '.ttf', '.otf', '.woff', '.woff2', '.eot',
      '.zip', '.tar', '.gz', '.7z', '.rar',
      '.pdf', '.doc', '.docx', '.xls', '.xlsx',
      '.mp3', '.mp4', '.avi', '.mov', '.wav',
      '.exe', '.dll', '.so', '.dylib',
    };
    
    return binaryExtensions.contains(getFileExtension(filePath));
  }

  /// Copy file with progress callback
  Future<void> copyFile(String sourcePath, String destinationPath, {
    void Function(int transferred, int total)? onProgress,
  }) async {
    final sourceFile = File(sourcePath);
    final destinationFile = File(destinationPath);
    
    if (!sourceFile.existsSync()) {
      throw FileSystemException('Source file does not exist', sourcePath);
    }

    final sourceLength = await sourceFile.length();
    final sourceStream = sourceFile.openRead();
    final destinationSink = destinationFile.openWrite();

    var transferred = 0;
    
    await for (final chunk in sourceStream) {
      destinationSink.add(chunk);
      transferred += chunk.length;
      onProgress?.call(transferred, sourceLength);
    }

    await destinationSink.close();
  }

  /// Clean up temporary files
  Future<void> cleanupTempFiles(List<String> tempPaths) async {
    for (final tempPath in tempPaths) {
      try {
        final entity = FileSystemEntity.typeSync(tempPath);
        switch (entity) {
          case FileSystemEntityType.file:
            await File(tempPath).delete();
            break;
          case FileSystemEntityType.directory:
            await Directory(tempPath).delete(recursive: true);
            break;
          default:
            // Skip other types
            break;
        }
      } catch (e) {
        // Ignore cleanup errors
        continue;
      }
    }
  }
}