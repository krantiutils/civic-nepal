import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_pdf_compression/simple_pdf_compression.dart';

/// Read file bytes from path (mobile only)
Future<Uint8List?> readFileBytes(String path) async {
  try {
    final file = File(path);
    return await file.readAsBytes();
  } catch (e) {
    debugPrint('Error reading file: $e');
    return null;
  }
}

/// Compress PDF using simple_pdf_compression package
Future<Uint8List?> compressPdf(
  Uint8List pdfBytes, {
  required int quality,
  required String filename,
}) async {
  try {
    // Write input bytes to temp file
    final tempDir = await getTemporaryDirectory();
    final inputFile = File('${tempDir.path}/input_$filename');
    await inputFile.writeAsBytes(pdfBytes);

    // Compress using the package
    final compressor = PDFCompression();
    final compressedFile = await compressor.compressPdf(
      inputFile,
      quality: quality,
    );

    // Read compressed bytes
    final compressedBytes = await compressedFile.readAsBytes();

    // Clean up temp files
    try {
      await inputFile.delete();
      if (compressedFile.path != inputFile.path) {
        await compressedFile.delete();
      }
    } catch (_) {
      // Ignore cleanup errors
    }

    return compressedBytes;
  } catch (e) {
    debugPrint('Error compressing PDF: $e');
    return null;
  }
}

/// Share PDF file
Future<void> sharePdf(Uint8List bytes, {required String filename}) async {
  try {
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
Future<bool> savePdf(Uint8List bytes, {required String filename}) async {
  try {
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
