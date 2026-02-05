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
                  if (team.logo != null)
                    Image.network(
                      team.logo!,
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
                    if (team.country != null)
                      _buildInfoRow(context, 'Country', team.country!),
                    if (team.founded != null)
                      _buildInfoRow(
                        context,
                        'Founded',
                        team.founded.toString(),
                      ),
                    if (team.venue != null)
                      _buildInfoRow(context, 'Stadium', team.venue!),
                    if (team.venueCapacity != null)
                      _buildInfoRow(
                        context,
                        'Capacity',
                        team.venueCapacity.toString(),
                      ),
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
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
