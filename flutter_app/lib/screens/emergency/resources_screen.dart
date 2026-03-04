import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../models/earthquake.dart';
import '../../widgets/home_title.dart';

/// Emergency resources screen
class EmergencyResourcesScreen extends StatelessWidget {
  const EmergencyResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNepali = l10n.isNepali;

    return Scaffold(
      appBar: AppBar(
        title: HomeTitle(child: Text(l10n.resourcesTab)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.resourcesInfo,
                      style: TextStyle(color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Resource cards
          ...emergencyResources.map((resource) => _ResourceCard(
                resource: resource,
                isNepali: isNepali,
              )),

          const SizedBox(height: 24),

          // Earthquake safety tips
          Text(
            l10n.safetyTips,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _SafetyTipsCard(),
        ],
      ),
    );
  }
}

class _ResourceCard extends StatelessWidget {
  final EmergencyResource resource;
  final bool isNepali;

  const _ResourceCard({
    required this.resource,
    required this.isNepali,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => launchUrl(Uri.parse(resource.url),
            mode: LaunchMode.externalApplication),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForResource(resource.icon),
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNepali ? resource.nameNp : resource.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isNepali ? resource.descriptionNp : resource.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForResource(String icon) {
    switch (icon) {
      case 'cloud':
        return Icons.cloud;
      case 'road':
        return Icons.directions_car;
      case 'earthquake':
        return Icons.ssid_chart;
      case 'medical':
        return Icons.medical_services;
      case 'warning':
        return Icons.warning_amber;
      case 'air':
        return Icons.air;
      default:
        return Icons.link;
    }
  }
}

class _SafetyTipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final tips = [
      (Icons.table_restaurant, l10n.safetyTip1),
      (Icons.door_front_door, l10n.safetyTip2),
      (Icons.electric_bolt, l10n.safetyTip3),
      (Icons.home, l10n.safetyTip4),
      (Icons.backpack, l10n.safetyTip5),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(tip.$1, size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(tip.$2, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
