import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import '../src/config.dart';
import '../utils/logger.dart';

/// Service for uploading built packages to various services
class UploadService {
  final Config config;
  final Logger _logger;

  UploadService(this.config) : _logger = Logger(config.verbose);

  /// Upload the zip file to the configured service
  Future<bool> upload() async {
    return await _uploadToTmpFiles();
  }

  Future<bool> _uploadToTmpFiles() async {
    final zipPath = path.join(config.buildDir, config.zipName);
    final zipFile = File(zipPath);

    if (!zipFile.existsSync()) {
      _logger.printError('Zip file not found: $zipPath');
      return false;
    }

    try {
      // Create multipart request
      final uri = Uri.parse(Config.uploadUrls['tmpfiles']!);
      final request = http.MultipartRequest('POST', uri);

      // Add file
      final fileStream = http.ByteStream(zipFile.openRead());
      final fileLength = await zipFile.length();

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: config.zipName,
      );

      request.files.add(multipartFile);

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return _handleTmpFilesResponse(response.body);
      } else {
        _logger.printError('Upload failed (${response.statusCode})');
        if (config.verbose) {
          _logger.printError('Response: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      _logger.printError('Upload failed: $e');
      return false;
    }
  }

  bool _handleTmpFilesResponse(String responseBody) {
    try {
      final jsonResponse = jsonDecode(responseBody);

      if (jsonResponse['status'] == 'success' && jsonResponse['data'] != null) {
        final data = jsonResponse['data'];
        final originalUrl = data['url'] as String?;

        if (originalUrl != null) {
          // Convert URL for direct download
          final downloadUrl =
              originalUrl.replaceAll('tmpfiles.org/', 'tmpfiles.org/dl/');

          if (config.verbose) {
            print('🔗 View: $originalUrl');
            print('🔗 Download: $downloadUrl');
          } else {
            print('🔗 $downloadUrl');
          }

          return true;
        }
      }

      // Try alternative response format
      if (jsonResponse['url'] != null) {
        final originalUrl = jsonResponse['url'] as String;
        final downloadUrl =
            originalUrl.replaceAll('tmpfiles.org/', 'tmpfiles.org/dl/');

        if (config.verbose) {
          print('🔗 View: $originalUrl');
          print('🔗 Download: $downloadUrl');
        } else {
          print('🔗 $downloadUrl');
        }

        return true;
      }

      _logger.printError('Unexpected response format');
      if (config.verbose) {
        _logger.printError('Response: $responseBody');
      }
      return false;
    } catch (e) {
      _logger.printError('Failed to parse response: $e');
      if (config.verbose) {
        _logger.printError('Response: $responseBody');
      }
      return false;
    }
  }
}
