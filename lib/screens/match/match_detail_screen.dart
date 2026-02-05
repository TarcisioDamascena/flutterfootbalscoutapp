import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/match.dart';
import '../../models/odds.dart';
import '../../providers/match_provider.dart';
import '../../providers/odds_provider.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  Odds? _odds;
  bool _isLoadingOdds = false;

  @override
  void initState() {
    super.initState();
    _loadOddsAndData();
  }

  Future<void> _loadOddsAndData() async {
    setState(() => _isLoadingOdds = true);

    // Fetch recent matches for both teams
    final matchProvider = context.read<MatchProvider>();
    final homeMatches = await matchProvider.fetchTeamMatches(
      teamId: widget.match.homeTeam.id,
      season: 2024,
      last: 5,
    );
    final awayMatches = await matchProvider.fetchTeamMatches(
      teamId: widget.match.awayTeam.id,
      season: 2024,
      last: 5,
    );

    // Fetch head-to-head
    final h2hMatches = await matchProvider.fetchHeadToHead(
      team1Id: widget.match.homeTeam.id,
      team2Id: widget.match.awayTeam.id,
      last: 5,
    );

    // Calculate odds
    final oddsProvider = context.read<OddsProvider>();
    final odds = await oddsProvider.calculateMatchOdds(
      match: widget.match,
      homeTeamRecentMatches: homeMatches,
      awayTeamRecentMatches: awayMatches,
      headToHeadMatches: h2hMatches,
    );

    setState(() {
      _odds = odds;
      _isLoadingOdds = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMatchHeader(),
            const SizedBox(height: 24),
            _buildOddsSection(),
            const SizedBox(height: 24),
            _buildMatchInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchHeader() {
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      if (widget.match.homeTeam.logo != null)
                        Image.network(
                          widget.match.homeTeam.logo!,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.shield, size: 60),
                        )
                      else
                        const Icon(Icons.shield, size: 60),
                      const SizedBox(height: 8),
                      Text(
                        widget.match.homeTeam.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    if (widget.match.isFinished)
                      Text(
                        widget.match.result,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      )
                    else if (widget.match.isLive)
                      Column(
                        children: [
                          Text(
                            widget.match.result,
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'VS',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                      ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      if (widget.match.awayTeam.logo != null)
                        Image.network(
                          widget.match.awayTeam.logo!,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.shield, size: 60),
                        )
                      else
                        const Icon(Icons.shield, size: 60),
                      const SizedBox(height: 8),
                      Text(
                        widget.match.awayTeam.name,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              dateFormat.format(widget.match.date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.match.venue != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stadium, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    widget.match.venue!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOddsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Match Odds', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_isLoadingOdds)
              const Center(child: CircularProgressIndicator())
            else if (_odds != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildOddsColumn(
                    label: 'Home Win',
                    odds: _odds!.homeWinOdds,
                    probability: _odds!.homeWinProbability,
                  ),
                  _buildOddsColumn(
                    label: 'Draw',
                    odds: _odds!.drawOdds,
                    probability: _odds!.drawProbability,
                  ),
                  _buildOddsColumn(
                    label: 'Away Win',
                    odds: _odds!.awayWinOdds,
                    probability: _odds!.awayWinProbability,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Source: ${_odds!.source.toUpperCase()}',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ] else
              const Center(child: Text('Unable to calculate odds')),
          ],
        ),
      ),
    );
  }

  Widget _buildOddsColumn({
    required String label,
    required double odds,
    double? probability,
  }) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        Text(
          odds.toStringAsFixed(2),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        if (probability != null) ...[
          const SizedBox(height: 4),
          Text(
            '${probability.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _buildMatchInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Match Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('League', widget.match.leagueName ?? 'N/A'),
            if (widget.match.round != null)
              _buildInfoRow('Round', widget.match.round.toString()),
            _buildInfoRow('Status', widget.match.status),
            if (widget.match.referee != null)
              _buildInfoRow('Referee', widget.match.referee!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
