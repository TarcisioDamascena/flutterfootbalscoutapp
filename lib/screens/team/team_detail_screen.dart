import 'package:flutter/material.dart';
import '../../models/team.dart';

class TeamDetailScreen extends StatelessWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(team.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  if (team.crest != null)
                    Image.network(
                      team.crest!,
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.shield, size: 120),
                    )
                  else
                    const Icon(Icons.shield, size: 120),
                  const SizedBox(height: 16),
                  Text(
                    team.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (team.shortName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      team.shortName!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Team Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (team.tla != null)
                      _buildInfoRow(context, 'Abbreviation', team.tla!),
                    if (team.founded != null)
                      _buildInfoRow(
                        context,
                        'Founded',
                        team.founded.toString(),
                      ),
                    if (team.clubColors != null)
                      _buildInfoRow(context, 'Colors', team.clubColors!),
                    if (team.venue != null)
                      _buildInfoRow(context, 'Stadium', team.venue!),
                    if (team.address != null)
                      _buildInfoRow(context, 'Address', team.address!),
                    if (team.website != null) _buildWebsiteRow(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Website',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: GestureDetector(
              onTap: () {
                // You can add url_launcher package to open the website
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(team.website!)));
              },
              child: Text(
                team.website!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
