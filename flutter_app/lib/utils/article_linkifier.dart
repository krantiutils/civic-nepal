import '../models/constitution.dart';

/// Base class for text segments
abstract class TextSegment {
  const TextSegment();
}

/// Plain text segment
class PlainTextSegment extends TextSegment {
  final String text;
  const PlainTextSegment(this.text);
}

/// Article reference segment
class ArticleRefSegment extends TextSegment {
  final String displayText;
  final int articleNumber;
  const ArticleRefSegment({
    required this.displayText,
    required this.articleNumber,
  });
}

/// Result of finding an article by number
class ArticleLocation {
  final int partIndex;
  final int articleIndex;

  const ArticleLocation({
    required this.partIndex,
    required this.articleIndex,
  });
}

/// Utility class for linkifying article references in text
class ArticleLinkifier {
  // Combined regex pattern that matches both English and Nepali article references
  static final RegExp _articlePattern = RegExp(
    r'(?:\b(Article)\s+(\d+)|(धारा)\s*([०-९]+))',
    caseSensitive: false,
  );

  // Devanagari numeral to Arabic numeral mapping
  static const Map<String, int> _devanagariToArabic = {
    '०': 0, '१': 1, '२': 2, '३': 3, '४': 4,
    '५': 5, '६': 6, '७': 7, '८': 8, '९': 9,
  };

  /// Parse text into segments, identifying article references
  static List<TextSegment> parseText(String text) {
    if (text.isEmpty) return [const PlainTextSegment('')];

    final segments = <TextSegment>[];
    int lastIndex = 0;

    for (final match in _articlePattern.allMatches(text)) {
      // Add plain text before this match
      if (match.start > lastIndex) {
        segments.add(PlainTextSegment(text.substring(lastIndex, match.start)));
      }

      // Determine which group matched
      final englishPrefix = match.group(1);
      final nepaliPrefix = match.group(3);

      int articleNumber;
      String displayText;

      if (englishPrefix != null) {
        // English match: "Article 42"
        articleNumber = int.parse(match.group(2)!);
        displayText = match.group(0)!;
      } else {
        // Nepali match: "धारा ४२"
        final devanagariNum = match.group(4)!;
        articleNumber = _devanagariToArabicNumeral(devanagariNum);
        displayText = match.group(0)!;
      }

      segments.add(ArticleRefSegment(
        displayText: displayText,
        articleNumber: articleNumber,
      ));

      lastIndex = match.end;
    }

    // Add remaining text
    if (lastIndex < text.length) {
      segments.add(PlainTextSegment(text.substring(lastIndex)));
    }

    return segments.isEmpty ? [PlainTextSegment(text)] : segments;
  }

  /// Check if text contains any article references
  static bool hasArticleReferences(String text) {
    return _articlePattern.hasMatch(text);
  }

  /// Convert Devanagari numeral string to integer
  static int _devanagariToArabicNumeral(String devanagari) {
    int result = 0;
    for (final char in devanagari.split('')) {
      result = result * 10 + (_devanagariToArabic[char] ?? 0);
    }
    return result;
  }

  /// Find an article by its number across all parts
  static ArticleLocation? findArticle(ConstitutionData constitution, int articleNumber) {
    for (int p = 0; p < constitution.parts.length; p++) {
      final part = constitution.parts[p];
      for (int a = 0; a < part.articles.length; a++) {
        final article = part.articles[a];
        // Extract number from article.number (e.g., "Article 1" -> 1)
        final extractedNumber = _extractArticleNumber(article.number);
        if (extractedNumber == articleNumber) {
          return ArticleLocation(partIndex: p, articleIndex: a);
        }
      }
    }
    return null;
  }

  /// Extract numeric article number from article.number string
  static int? _extractArticleNumber(String articleNumberStr) {
    // Try to extract number from strings like "Article 1", "धारा १", etc.
    // First try Arabic numerals
    final arabicMatch = RegExp(r'\b(\d+)\b').firstMatch(articleNumberStr);
    if (arabicMatch != null) {
      return int.parse(arabicMatch.group(1)!);
    }

    // Try Devanagari numerals
    final devanagariMatch = RegExp(r'[०-९]+').firstMatch(articleNumberStr);
    if (devanagariMatch != null) {
      return _devanagariToArabicNumeral(devanagariMatch.group(0)!);
    }

    return null;
  }
}
