import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../models/earthquake.dart';
import '../../widgets/home_title.dart';

/// Emergency contacts screen
class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isNepali = l10n.isNepali;

    return Scaffold(
      appBar: AppBar(
        title: HomeTitle(child: Text(l10n.contacts)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Safety tip card
          Card(
            color: Colors.amber.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.emergencyTip,
                      style: TextStyle(color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Emergency contacts list
          ...nepalEmergencyContacts.map((contact) => _EmergencyContactCard(
                contact: contact,
                isNepali: isNepali,
              )),
        ],
      ),
    );
  }
}

class _EmergencyContactCard extends StatelessWidget {
  final EmergencyContact contact;
  final bool isNepali;

  const _EmergencyContactCard({
    required this.contact,
    required this.isNepali,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _makeCall(contact.number),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    contact.number,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
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
                      isNepali ? contact.nameNp : contact.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (contact.description != null)
                      Text(
                        isNepali
                            ? (contact.descriptionNp ?? contact.description!)
                            : contact.description!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.call,
                color: Colors.green.shade600,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
