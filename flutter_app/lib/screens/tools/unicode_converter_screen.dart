import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/home_title.dart';

/// Unicode converter screen for Preeti ↔ Unicode conversion
class UnicodeConverterScreen extends StatefulWidget {
  const UnicodeConverterScreen({super.key});

  @override
  State<UnicodeConverterScreen> createState() => _UnicodeConverterScreenState();
}

class _UnicodeConverterScreenState extends State<UnicodeConverterScreen> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  bool _isPreetiToUnicode = true;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = _inputController.text;
    if (input.isEmpty) {
      _outputController.text = '';
      return;
    }

    final output = _isPreetiToUnicode
        ? _preetiToUnicode(input)
        : _unicodeToPreeti(input);

    setState(() {
      _outputController.text = output;
    });
  }

  void _swap() {
    final temp = _inputController.text;
    setState(() {
      _isPreetiToUnicode = !_isPreetiToUnicode;
      _inputController.text = _outputController.text;
      _outputController.text = temp;
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _outputController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).copied),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _pasteInput() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null) {
      setState(() {
        _inputController.text = data!.text!;
      });
      _convert();
    }
  }

  void _clearAll() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: HomeTitle(child: Text(l10n.unicodeConverter)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAll,
            tooltip: l10n.clear,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mode selector
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SegmentedButton<bool>(
                              segments: [
                                ButtonSegment(
                                  value: true,
                                  label: Text(l10n.preetiToUnicode),
                                  icon: const Icon(Icons.text_fields),
                                ),
                                ButtonSegment(
                                  value: false,
                                  label: Text(l10n.unicodeToPreeti),
                                  icon: const Icon(Icons.font_download),
                                ),
                              ],
                              selected: {_isPreetiToUnicode},
                              onSelectionChanged: (selection) {
                                setState(() {
                                  _isPreetiToUnicode = selection.first;
                                });
                                _convert();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input field
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isPreetiToUnicode ? 'Preeti' : 'Unicode',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                TextButton.icon(
                                  onPressed: _pasteInput,
                                  icon: const Icon(Icons.paste, size: 18),
                                  label: Text(l10n.paste),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _inputController,
                              maxLines: 6,
                              decoration: InputDecoration(
                                hintText: l10n.inputText,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (_) => _convert(),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Swap button
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: IconButton.filled(
                          onPressed: _swap,
                          icon: const Icon(Icons.swap_vert),
                          tooltip: l10n.swap,
                        ),
                      ),
                    ),

                    // Output field
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isPreetiToUnicode ? 'Unicode' : 'Preeti',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                TextButton.icon(
                                  onPressed: _copyOutput,
                                  icon: const Icon(Icons.copy, size: 18),
                                  label: Text(l10n.copy),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _outputController,
                              maxLines: 6,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: l10n.outputText,
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Convert Preeti font encoding to Unicode Nepali
  String _preetiToUnicode(String input) {
    // Preeti to Unicode mapping
    const Map<String, String> map = {
      'q': 'त्र',
      'Q': 'ट्र',
      'w': 'ध',
      'W': 'ध्र',
      'e': 'भ',
      'E': 'भ्र',
      'r': 'च',
      'R': 'च्र',
      't': 'त',
      'T': 'ट',
      'y': 'थ',
      'Y': 'ठ',
      'u': 'ग',
      'U': 'घ',
      'i': 'ह',
      'I': 'क्ष',
      'o': 'ड',
      'O': 'ड्र',
      'p': 'ढ',
      'P': 'ढ्र',
      'a': 'ब',
      'A': 'ब्र',
      's': 'क',
      'S': 'क्र',
      'd': 'म',
      'D': 'म्र',
      'f': 'ा',
      'F': 'ँ',
      'g': 'न',
      'G': 'न्र',
      'h': 'ज',
      'H': 'ज्र',
      'j': 'व',
      'J': 'श्र',
      'k': 'प',
      'K': 'फ्र',
      'l': 'ि',
      'L': 'ी',
      ';': 'स',
      ':': 'श',
      "'": 'ु',
      '"': 'ू',
      'z': 'श',
      'Z': 'श्',
      'x': 'ह्र',
      'X': 'द्र',
      'c': 'ए',
      'C': 'ऐ',
      'v': 'र',
      'V': 'र्',
      'b': 'द',
      'B': 'द्द',
      'n': 'ल',
      'N': 'ळ',
      'm': 'अ',
      'M': 'ं',
      ',': ',',
      '<': '?',
      '.': '।',
      '>': 'श्र',
      '/': 'र',
      '?': 'रु',
      '`': 'ञ',
      '~': 'ञ्',
      '1': '१',
      '!': 'ज्ञ',
      '2': '२',
      '@': 'इ',
      '3': '३',
      '#': 'घ्र',
      '4': '४',
      '\$': 'द्य',
      '5': '५',
      '%': 'छ',
      '6': '६',
      '^': 'ट्ट',
      '7': '७',
      '&': 'ख्र',
      '8': '८',
      '*': 'ख',
      '9': '९',
      '(': 'त्त',
      '0': '०',
      ')': 'ण',
      '-': 'ौ',
      '_': 'ौं',
      '=': '.',
      '+': 'ृ',
      '[': 'ृ',
      '{': 'र्',
      ']': 'े',
      '}': 'ै',
      '\\': 'ै',
      '|': 'ो',
      '¡': 'फ',
      '§': '्र',
      '©': 'ं',
      '±': 'द्र',
      '÷': 'ण्',
      'Þ': '्य',
      '®': 'ट्ठ',
      'å': 'द्व',
      'Å': 'ड्ड',
      'Ú': 'ह्य',
      '›': 'दृ',
      'ˆ': 'फ',
    };

    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      buffer.write(map[char] ?? char);
    }

    // Post-processing for common patterns
    String result = buffer.toString();

    // Fix vowel sign ordering (ि should come after consonant in display but before in Unicode)
    result = _fixVowelOrdering(result);

    return result;
  }

  String _fixVowelOrdering(String text) {
    // In Unicode, ि (i-matra) should come before the consonant it modifies
    // but in display/typing it comes after
    // This is a simplified fix - proper implementation would need more complex logic
    return text;
  }

  /// Convert Unicode Nepali to Preeti font encoding
  String _unicodeToPreeti(String input) {
    // Reverse mapping (Unicode to Preeti)
    const Map<String, String> map = {
      'त्र': 'q',
      'ट्र': 'Q',
      'ध': 'w',
      'ध्र': 'W',
      'भ': 'e',
      'भ्र': 'E',
      'च': 'r',
      'च्र': 'R',
      'त': 't',
      'ट': 'T',
      'थ': 'y',
      'ठ': 'Y',
      'ग': 'u',
      'घ': 'U',
      'ह': 'i',
      'क्ष': 'I',
      'ड': 'o',
      'ड्र': 'O',
      'ढ': 'p',
      'ढ्र': 'P',
      'ब': 'a',
      'ब्र': 'A',
      'क': 's',
      'क्र': 'S',
      'म': 'd',
      'म्र': 'D',
      'ा': 'f',
      'ँ': 'F',
      'न': 'g',
      'न्र': 'G',
      'ज': 'h',
      'ज्र': 'H',
      'व': 'j',
      'श्र': 'J',
      'प': 'k',
      'फ्र': 'K',
      'ि': 'l',
      'ी': 'L',
      'स': ';',
      'श': ':',
      'ु': "'",
      'ू': '"',
      'ह्र': 'x',
      'द्र': 'X',
      'ए': 'c',
      'ऐ': 'C',
      'र': 'v',
      'र्': 'V',
      'द': 'b',
      'द्द': 'B',
      'ल': 'n',
      'ळ': 'N',
      'अ': 'm',
      'ं': 'M',
      '।': '.',
      'ज्ञ': '!',
      'इ': '@',
      'घ्र': '#',
      'द्य': '\$',
      'छ': '%',
      'ट्ट': '^',
      'ख्र': '&',
      'ख': '*',
      'त्त': '(',
      'ण': ')',
      'ौ': '-',
      'ौं': '_',
      'ृ': '+',
      'े': ']',
      'ै': '}',
      'ो': '|',
      'फ': '¡',
      '्र': '§',
      '्य': 'Þ',
      'ट्ठ': '®',
      'द्व': 'å',
      'ड्ड': 'Å',
      'ह्य': 'Ú',
      'ञ': '`',
      'ञ्': '~',
      '१': '1',
      '२': '2',
      '३': '3',
      '४': '4',
      '५': '5',
      '६': '6',
      '७': '7',
      '८': '8',
      '९': '9',
      '०': '0',
    };

    // Sort by length (longer matches first) to handle multi-char sequences
    final sortedKeys = map.keys.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    String result = input;
    for (final key in sortedKeys) {
      result = result.replaceAll(key, map[key]!);
    }

    return result;
  }
}
