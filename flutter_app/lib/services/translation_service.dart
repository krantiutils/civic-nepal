import 'package:flutter/services.dart';

/// Service to load translations from CSV file
/// CSV format: key,english,nepali,newari,context
class TranslationService {
  static TranslationService? _instance;
  static TranslationService get instance => _instance ??= TranslationService._();

  TranslationService._();

  Map<String, Map<String, String>> _translations = {};
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// Get translations for a specific locale code
  Map<String, String> getTranslations(String localeCode) {
    return _translations[localeCode] ?? _translations['en'] ?? {};
  }

  /// Load translations from CSV asset
  Future<void> loadTranslations() async {
    if (_isLoaded) return;

    try {
      final csvString = await rootBundle.loadString('assets/translations/ui_strings.csv');
      _parseCSV(csvString);
      _isLoaded = true;
    } catch (e) {
      // Fallback to empty translations if loading fails
      _translations = {
        'en': {},
        'ne': {},
        'new': {},
        'mai': {},
      };
      _isLoaded = true;
      rethrow;
    }
  }

  void _parseCSV(String csvContent) {
    final lines = csvContent.split('\n');
    if (lines.isEmpty) return;

    // Initialize maps for each locale
    final english = <String, String>{};
    final nepali = <String, String>{};
    final newari = <String, String>{};
    final maithili = <String, String>{};

    // Skip header line and parse each row
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();

      // Skip empty lines and comments
      if (line.isEmpty || line.startsWith('#')) continue;

      final values = _parseCSVLine(line);
      if (values.length < 4) continue;

      final key = values[0].trim();
      if (key.isEmpty) continue;

      // CSV columns: key, english, nepali, newari, context
      final enValue = values[1].trim();
      final npValue = values[2].trim();
      final newValue = values.length > 3 ? values[3].trim() : '';
      // context column (index 4) is ignored - it's for documentation

      if (enValue.isNotEmpty) english[key] = enValue;
      if (npValue.isNotEmpty) nepali[key] = npValue;
      if (newValue.isNotEmpty) newari[key] = newValue;
      // Maithili not in current CSV but we keep the slot
    }

    _translations = {
      'en': english,
      'ne': nepali,
      'new': newari,
      'mai': maithili,
    };
  }

  /// Parse a CSV line handling quoted values with commas
  List<String> _parseCSVLine(String line) {
    final values = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        // Check for escaped quote
        if (i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++; // Skip next quote
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        values.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }

    // Don't forget the last value
    values.add(current.toString());

    return values;
  }

  /// Reload translations (useful for hot reload during development)
  Future<void> reloadTranslations() async {
    _isLoaded = false;
    await loadTranslations();
  }
}
