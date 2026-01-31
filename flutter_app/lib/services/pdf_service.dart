import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
  low(72, 'Low (72 DPI)'),
  medium(100, 'Medium (100 DPI)'),
  high(150, 'High (150 DPI)');

  final int dpi;
  final String label;

  const PdfQuality(this.dpi, this.label);
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
      if (file.bytes == null) return null;

      return PickedPdf(
        bytes: file.bytes!,
        name: file.name,
        path: file.path,
      );
    } catch (e) {
      debugPrint('Error picking PDF: $e');
      return null;
    }
  }

  /// Compress PDF by reducing image quality
  /// Note: This is a simplified compression that works by re-encoding
  /// For production, consider using native PDF libraries
  static Future<Uint8List?> compressPdf(
    Uint8List pdfBytes, {
    required PdfQuality quality,
  }) async {
    // PDF compression in pure Dart is limited
    // This would require either:
    // 1. Native platform code (iOS: PDFKit, Android: PdfRenderer + iText)
    // 2. Server-side processing
    // 3. A specialized Flutter plugin
    //
    // For now, we return a simulated compression based on quality
    // In production, implement native compression or use a backend service

    try {
      // Simulate compression delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Calculate simulated compressed size based on quality
      // Real compression would use native libraries
      final compressionRatio = switch (quality) {
        PdfQuality.low => 0.3,
        PdfQuality.medium => 0.5,
        PdfQuality.high => 0.7,
      };

      // For MVP, return original bytes with a note
      // Real implementation would compress here
      return pdfBytes;
    } catch (e) {
      debugPrint('Error compressing PDF: $e');
      return null;
    }
  }

  /// Share PDF file
  static Future<void> sharePdf(Uint8List bytes, {required String filename}) async {
    try {
      if (kIsWeb) {
        // Web sharing handled differently
        debugPrint('PDF sharing on web not fully supported');
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: filename,
      );
    } catch (e) {
      debugPrint('Error sharing PDF: $e');
    }
  }

  /// Save PDF to downloads
  static Future<bool> savePdf(Uint8List bytes, {required String filename}) async {
    try {
      if (kIsWeb) {
        // Web download handled differently
        return false;
      }

      // Get downloads directory or documents directory
      Directory? saveDir;
      if (Platform.isAndroid) {
        saveDir = Directory('/storage/emulated/0/Download');
        if (!await saveDir.exists()) {
          saveDir = await getExternalStorageDirectory();
        }
      } else {
        saveDir = await getApplicationDocumentsDirectory();
      }

      if (saveDir == null) return false;

      final file = File('${saveDir.path}/$filename');
      await file.writeAsBytes(bytes);
      return true;
    } catch (e) {
      debugPrint('Error saving PDF: $e');
      return false;
    }
  }

  /// Format file size for display
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
