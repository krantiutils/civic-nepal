import 'dart:typed_data';

/// Stub implementation - should never be used
/// Actual implementations are in pdf_service_mobile.dart and pdf_service_web.dart

Future<Uint8List?> readFileBytes(String path) async {
  throw UnimplementedError('Platform not supported');
}

Future<Uint8List?> compressPdf(
  Uint8List pdfBytes, {
  required int quality,
  required String filename,
}) async {
  throw UnimplementedError('Platform not supported');
}

Future<void> sharePdf(Uint8List bytes, {required String filename}) async {
  throw UnimplementedError('Platform not supported');
}

Future<bool> savePdf(Uint8List bytes, {required String filename}) async {
  throw UnimplementedError('Platform not supported');
}
