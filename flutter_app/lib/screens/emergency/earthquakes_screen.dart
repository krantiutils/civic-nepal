import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../models/earthquake.dart';
import '../../providers/earthquake_provider.dart';
import '../../widgets/home_title.dart';

/// Full earthquakes list screen
class EarthquakesScreen extends ConsumerWidget {
  const EarthquakesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final earthquakesAsync = ref.watch(recentEarthquakesProvider);
    final minMag = ref.watch(earthquakeMinMagnitudeProvider);

    return Scaffold(
      appBar: AppBar(
        title: HomeTitle(child: Text(l10n.earthquakesTab)),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: l10n.viewOnUsgs,
            onPressed: () => _openUsgs(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Row(
              children: [
                Text('${l10n.minMagnitude}: '),
                Expanded(
                  child: Slider(
                    value: minMag,
                    min: 2.0,
                    max: 6.0,
                    divisions: 8,
                    label: minMag.toStringAsFixed(1),
                    onChanged: (v) =>
                        ref.read(earthquakeMinMagnitudeProvider.notifier).set(v),
                  ),
                ),
                Text(minMag.toStringAsFixed(1)),
              ],
            ),
          ),

          // Earthquakes list
          Expanded(
            child: earthquakesAsync.when(
              data: (earthquakes) {
                final filtered =
                    earthquakes.where((e) => e.magnitude >= minMag).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            size: 64, color: Colors.green.shade300),
                        const SizedBox(height: 16),
                        Text(l10n.noEarthquakes),
                        Text(
                          l10n.noEarthquakesDesc,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(recentEarthquakesProvider.future),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _EarthquakeCard(earthquake: filtered[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(l10n.errorLoading),
                    const SizedBox(height: 8),
                    FilledButton.icon(
                      onPressed: () =>
                          ref.refresh(recentEarthquakesProvider.future),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Data source attribution
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              l10n.dataFromUsgs,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUsgs() async {
    final uri = Uri.parse(
        'https://earthquake.usgs.gov/earthquakes/map/?extent=24.44,78.30&extent=31.54,90.90');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _EarthquakeCard extends StatelessWidget {
  final Earthquake earthquake;

  const _EarthquakeCard({required this.earthquake});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final magColor = _getMagnitudeColor(earthquake.magnitude);
    final timeAgo = _formatTimeAgo(earthquake.time);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: earthquake.url != null
            ? () => launchUrl(Uri.parse(earthquake.url!))
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Magnitude badge
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: magColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: magColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    earthquake.magnitude.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: magColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      earthquake.place,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.arrow_downward,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${earthquake.depth.toStringAsFixed(1)} km',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (earthquake.url != null)
                Icon(Icons.open_in_new,
                    size: 20, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  Color _getMagnitudeColor(double magnitude) {
    if (magnitude >= 6.0) return Colors.red.shade700;
    if (magnitude >= 5.0) return Colors.orange.shade700;
    if (magnitude >= 4.0) return Colors.amber.shade700;
    if (magnitude >= 3.0) return Colors.yellow.shade700;
    return Colors.green.shade600;
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    }
    return 'Just now';
  }
}
