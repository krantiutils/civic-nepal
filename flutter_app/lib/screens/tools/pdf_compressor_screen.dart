import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/pdf_service.dart';
import '../../widgets/home_title.dart';

/// Screen for compressing PDF files
class PdfCompressorScreen extends StatefulWidget {
  const PdfCompressorScreen({super.key});

  @override
  State<PdfCompressorScreen> createState() => _PdfCompressorScreenState();
}

class _PdfCompressorScreenState extends State<PdfCompressorScreen> {
  PickedPdf? _originalPdf;
  Uint8List? _compressedPdf;
  int _compressedSize = 0;
  bool _isLoading = false;
  bool _isCompressing = false;
  PdfQuality _selectedQuality = PdfQuality.medium;

  Future<void> _pickPdf() async {
    setState(() => _isLoading = true);
    try {
      final picked = await PdfService.pickPdf();
      if (picked != null && mounted) {
        setState(() {
          _originalPdf = picked;
          _compressedPdf = null;
          _compressedSize = 0;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _compressPdf() async {
    if (_originalPdf == null) return;

    setState(() => _isCompressing = true);

    try {
      final compressed = await PdfService.compressPdf(
        _originalPdf!.bytes,
        quality: _selectedQuality,
        filename: _originalPdf!.name,
      );

      if (compressed != null && mounted) {
        setState(() {
          _compressedPdf = compressed;
          _compressedSize = compressed.length;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to compress PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCompressing = false);
      }
    }
  }

  Future<void> _savePdf() async {
    final pdfToSave = _compressedPdf ?? _originalPdf?.bytes;
    if (pdfToSave == null) return;

    final filename = _compressedPdf != null
        ? 'compressed_${_originalPdf!.name}'
        : _originalPdf!.name;

    final success = await PdfService.savePdf(pdfToSave, filename: filename);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Saved to Downloads' : 'Failed to save'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _sharePdf() async {
    final pdfToShare = _compressedPdf ?? _originalPdf?.bytes;
    if (pdfToShare == null) return;

    final filename = _compressedPdf != null
        ? 'compressed_${_originalPdf!.name}'
        : _originalPdf!.name;

    await PdfService.sharePdf(pdfToShare, filename: filename);
  }

  void _reset() {
    setState(() {
      _originalPdf = null;
      _compressedPdf = null;
      _compressedSize = 0;
    });
  }

  String _getSavingsText() {
    if (_originalPdf == null || _compressedPdf == null) return '';
    final originalSize = _originalPdf!.size;
    final savedBytes = originalSize - _compressedSize;
    if (savedBytes <= 0) {
      return 'No size reduction (PDF may already be optimized)';
    }
    final percent = ((savedBytes / originalSize) * 100).toStringAsFixed(1);
    return 'Saved ${PdfService.getFileSizeString(savedBytes)} ($percent% smaller)';
  }

  bool get _hasCompression {
    if (_originalPdf == null || _compressedPdf == null) return false;
    return _compressedSize < _originalPdf!.size;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: HomeTitle(child: Text(l10n.pdfCompressor)),
        actions: [
          if (_originalPdf != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: l10n.reset,
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _originalPdf == null
                  ? _buildEmptyState(l10n)
                  : _buildCompressionView(l10n),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.picture_as_pdf,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.compressPdfs,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pdfCompressDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isLoading ? null : _pickPdf,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.upload_file),
              label: Text(l10n.selectPdf),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompressionView(AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PDF info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.picture_as_pdf, size: 40, color: Colors.red[700]),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _originalPdf!.name,
                          style: Theme.of(context).textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _SizeChip(
                              label: l10n.original,
                              size: _originalPdf!.size,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            if (_compressedPdf != null) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Icon(Icons.arrow_forward, size: 16),
                              ),
                              _SizeChip(
                                label: l10n.compressed,
                                size: _compressedSize,
                                color: _hasCompression ? Colors.green : Colors.orange,
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quality selector (only show if not yet compressed)
          if (_compressedPdf == null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quality,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<PdfQuality>(
                      segments: PdfQuality.values
                          .map((q) => ButtonSegment(
                                value: q,
                                label: Text(q.label),
                              ))
                          .toList(),
                      selected: {_selectedQuality},
                      onSelectionChanged: (selection) {
                        setState(() {
                          _selectedQuality = selection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Lower quality = smaller file size',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Compress button
            FilledButton.icon(
              onPressed: _isCompressing ? null : _compressPdf,
              icon: _isCompressing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.compress),
              label: Text(_isCompressing ? l10n.compressing : l10n.compress),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],

          // Results (show after compression)
          if (_compressedPdf != null) ...[
            // Savings display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasCompression ? Colors.green[50] : Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hasCompression ? Colors.green[200]! : Colors.orange[200]!,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _hasCompression ? Icons.check_circle : Icons.info_outline,
                    color: _hasCompression ? Colors.green[700] : Colors.orange[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getSavingsText(),
                      style: TextStyle(
                        color: _hasCompression ? Colors.green[700] : Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _savePdf,
                    icon: const Icon(Icons.save_alt),
                    label: Text(l10n.save),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _sharePdf,
                    icon: const Icon(Icons.share),
                    label: Text(l10n.share),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Compress again with different quality
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _compressedPdf = null;
                  _compressedSize = 0;
                });
              },
              icon: const Icon(Icons.tune),
              label: const Text('Try different quality'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SizeChip extends StatelessWidget {
  final String label;
  final int size;
  final Color color;

  const _SizeChip({
    required this.label,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: ${PdfService.getFileSizeString(size)}',
        style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}
