import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

// Conditional imports for platform-specific implementations
import 'pdf_service_stub.dart'
    if (dart.library.io) 'pdf_service_mobile.dart'
    if (dart.library.html) 'pdf_service_web.dart' as platform;

/// Picked PDF result
class PickedPdf {
  final Uint8List bytes;
  final String name;
  final String? path;

  PickedPdf({required this.bytes, required this.name, this.path});

  int get size => bytes.length;
}

/// Quality levels for PDF compression
enum PdfQuality {
  low(30, 'Low'),
  medium(50, 'Medium'),
  high(70, 'High');

  final int quality;
  final String label;

  const PdfQuality(this.quality, this.label);
}

/// Service for PDF operations
class PdfService {
  /// Pick a PDF file
  static Future<PickedPdf?> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      Uint8List? bytes = file.bytes;

      // On mobile, bytes might be null - read from path
      // On web, path is not available so we skip this
      if (bytes == null && !kIsWeb) {
        final path = file.path;
        if (path != null) {
          bytes = await platform.readFileBytes(path);
        }
      }

      if (bytes == null) {
        debugPrint('Could not get PDF bytes');
        return null;
      }

      return PickedPdf(
        bytes: bytes,
        name: file.name,
        path: kIsWeb ? null : file.path,
      );
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      return null;
    }
  }

  /// Compress PDF - available on all platforms
  static Future<Uint8List?> compressPdf(
    Uint8List pdfBytes, {
    required PdfQuality quality,
    required String filename,
  }) async {
    return platform.compressPdf(pdfBytes, quality: quality.quality, filename: filename);
  }

  /// Share PDF file (on web, triggers download)
  static Future<void> sharePdf(Uint8List bytes, {required String filename}) async {
    await platform.sharePdf(bytes, filename: filename);
  }

  /// Save PDF to downloads
  static Future<bool> savePdf(Uint8List bytes, {required String filename}) async {
    return platform.savePdf(bytes, filename: filename);
  }

  /// Format file size for display
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if compression is supported on current platform
  static bool get isCompressionSupported => !kIsWeb;
}
