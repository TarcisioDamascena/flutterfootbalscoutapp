import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/match.dart';
import '../../providers/match_provider.dart';

class MatchDetailScreen extends StatefulWidget {
  final Match match;

  const MatchDetailScreen({super.key, required this.match});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  List<Match> _h2hMatches = [];
  bool _isLoadingH2H = false;

  @override
  void initState() {
    super.initState();
    _loadHeadToHead();
  }

  Future<void> _loadHeadToHead() async {
    setState(() => _isLoadingH2H = true);

    final matchProvider = context.read<MatchProvider>();
    final h2hMatches = await matchProvider.fetchHeadToHead(
      team1Id: widget.match.homeTeam.id,
      team2Id: widget.match.awayTeam.id,
      limit: 5,
    );

    setState(() {
      _h2hMatches = h2hMatches;
      _isLoadingH2H = false;
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
            _buildMatchInfo(),
            const SizedBox(height: 24),
            _buildHeadToHead(),
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
                      if (widget.match.homeTeam.crest != null)
                        Image.network(
                          widget.match.homeTeam.crest!,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.shield, size: 60),
                        )
                      else
                        const Icon(Icons.shield, size: 60),
                      const SizedBox(height: 8),
                      Text(
                        widget.match.homeTeam.shortName ??
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
                      if (widget.match.awayTeam.crest != null)
                        Image.network(
                          widget.match.awayTeam.crest!,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.shield, size: 60),
                        )
                      else
                        const Icon(Icons.shield, size: 60),
                      const SizedBox(height: 8),
                      Text(
                        widget.match.awayTeam.shortName ??
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
              dateFormat.format(widget.match.utcDate),
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
            if (widget.match.leagueName != null)
              _buildInfoRow('Competition', widget.match.leagueName!),
            if (widget.match.matchday != null)
              _buildInfoRow('Matchday', widget.match.matchday.toString()),
            _buildInfoRow('Status', _getStatusText(widget.match.status)),
            _buildInfoRow('Stage', _formatStage(widget.match.stage)),
            if (widget.match.referee != null)
              _buildInfoRow('Referee', widget.match.referee!),
            if (widget.match.isFinished && widget.match.winner != null)
              _buildInfoRow('Winner', widget.match.winnerName),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadToHead() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Head to Head', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_isLoadingH2H)
              const Center(child: CircularProgressIndicator())
            else if (_h2hMatches.isEmpty)
              const Center(child: Text('No previous matches found'))
            else
              Column(
                children: _h2hMatches.map((match) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            match.homeTeam.shortName ?? match.homeTeam.name,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          match.result,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Expanded(
                          child: Text(
                            match.awayTeam.shortName ?? match.awayTeam.name,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
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

  String _getStatusText(String status) {
    switch (status) {
      case 'SCHEDULED':
      case 'TIMED':
        return 'Scheduled';
      case 'IN_PLAY':
        return 'In Play';
      case 'PAUSED':
        return 'Half Time';
      case 'FINISHED':
        return 'Finished';
      case 'POSTPONED':
        return 'Postponed';
      case 'CANCELLED':
        return 'Cancelled';
      case 'SUSPENDED':
        return 'Suspended';
      default:
        return status;
    }
  }

  String _formatStage(String stage) {
    return stage
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) {
          return word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1)
              : '';
        })
        .join(' ');
  }
}
