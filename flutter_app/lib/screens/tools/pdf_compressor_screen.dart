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
  bool _isProcessing = false;
  PdfQuality _selectedQuality = PdfQuality.medium;

  Future<void> _pickPdf() async {
    final picked = await PdfService.pickPdf();
    if (picked != null) {
      setState(() {
        _originalPdf = picked;
        _compressedPdf = null;
        _compressedSize = 0;
      });
    }
  }

  Future<void> _compressPdf() async {
    if (_originalPdf == null) return;

    setState(() => _isProcessing = true);

    try {
      final compressed = await PdfService.compressPdf(
        _originalPdf!.bytes,
        quality: _selectedQuality,
      );

      if (compressed != null && mounted) {
        setState(() {
          _compressedPdf = compressed;
          _compressedSize = compressed.length;
        });
      } else if (mounted) {
        _showError('Failed to compress PDF');
      }
    } catch (e) {
      if (mounted) {
        _showError('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _savePdf() async {
    final pdfToSave = _compressedPdf ?? _originalPdf?.bytes;
    if (pdfToSave == null) return;

    final filename = 'compressed_${_originalPdf!.name}';
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
                  ? _buildEmptyState()
                  : _buildCompressionView(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final l10n = AppLocalizations.of(context);
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
              onPressed: _pickPdf,
              icon: const Icon(Icons.upload_file),
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

  Widget _buildCompressionView() {
    final l10n = AppLocalizations.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // PDF info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
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
                            ),
                            const SizedBox(height: 4),
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
                                    color: Colors.green,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Compression note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.pdfCompressionNote,
                    style: TextStyle(color: Colors.blue[700], fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Quality selector
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
                        _compressedPdf = null;
                        _compressedSize = 0;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

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
