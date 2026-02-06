import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/match.dart';

class MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const MatchCard({super.key, required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (match.leagueName != null)
                Text(
                  match.leagueName!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildTeam(
                      context,
                      match.homeTeam.shortName ?? match.homeTeam.name,
                      match.homeTeam.crest,
                      match.homeScore,
                    ),
                  ),
                  Column(
                    children: [
                      if (match.isFinished || match.isLive)
                        Text(
                          match.result,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        )
                      else
                        Text(
                          dateFormat.format(match.utcDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      if (match.isLive) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Expanded(
                    child: _buildTeam(
                      context,
                      match.awayTeam.shortName ?? match.awayTeam.name,
                      match.awayTeam.crest,
                      match.awayScore,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeam(
    BuildContext context,
    String name,
    String? crest,
    int? score,
  ) {
    return Column(
      children: [
        if (crest != null)
          Image.network(
            crest,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.shield, size: 40),
          )
        else
          const Icon(Icons.shield, size: 40),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
