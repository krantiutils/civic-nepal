import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

/// Web implementation using MuPDF.js for proper PDF compression

// JS interop for MuPDF compression function
@JS('compressPdfWithMupdf')
external JSPromise<JSUint8Array?> _compressPdfWithMupdf(JSUint8Array data, JSNumber quality);

Future<Uint8List?> readFileBytes(String path) async {
  // Web doesn't have file paths - bytes come from picker directly
  return null;
}

/// Compress PDF using MuPDF.js (proper PDF compression with garbage collection)
Future<Uint8List?> compressPdf(
  Uint8List pdfBytes, {
  required int quality,
  required String filename,
}) async {
  try {
    // Convert Uint8List to JSUint8Array
    final jsData = pdfBytes.toJS;
    final jsQuality = quality.toJS;

    // Call MuPDF compression function
    final result = await _compressPdfWithMupdf(jsData, jsQuality).toDart;

    if (result == null) {
      debugPrint('MuPDF compression returned null');
      return null;
    }

    // Convert back to Uint8List
    final compressed = result.toDart;

    // If compressed is larger, return original
    if (compressed.length >= pdfBytes.length) {
      debugPrint('Compressed PDF is larger than original, returning original');
      return pdfBytes;
    }

    return compressed;
  } catch (e) {
    debugPrint('Error compressing PDF on web: $e');
    return null;
  }
}

/// Share PDF file on web (download)
Future<void> sharePdf(Uint8List bytes, {required String filename}) async {
  try {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement()
      ..href = url
      ..download = filename
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();

    html.Url.revokeObjectUrl(url);
  } catch (e) {
    debugPrint('Error sharing PDF on web: $e');
  }
}

/// Save PDF on web (same as share - triggers download)
Future<bool> savePdf(Uint8List bytes, {required String filename}) async {
  try {
    await sharePdf(bytes, filename: filename);
    return true;
  } catch (e) {
    debugPrint('Error saving PDF on web: $e');
    return false;
  }
}
