import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/match_provider.dart';
import '../../widgets/match_card.dart';
import '../../widgets/options_menu_button.dart';
import 'match_detail_screen.dart';

class MatchListScreen extends StatefulWidget {
  const MatchListScreen({super.key});

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  String _selectedLeague = AppConstants.defaultLeague;
  late int _selectedSeason;

  @override
  void initState() {
    super.initState();
    _selectedSeason = _currentSeason();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  int _currentSeason() {
    final now = DateTime.now();
    return now.month >= 7 ? now.year : now.year - 1;
  }

  Future<void> _loadMatches() async {
    final leagueId = AppConstants.leagueIds[_selectedLeague] ?? 39;
    await context.read<MatchProvider>().fetchFixtures(
      leagueId: leagueId,
      season: _selectedSeason,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.matches),
        actions: [
          const OptionsMenuButton(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedLeague = value;
                _selectedSeason = _currentSeason();
              });
              _loadMatches();
            },
            itemBuilder: (context) {
              return AppConstants.leagueIds.keys.map((league) {
                return PopupMenuItem<String>(value: league, child: Text(league));
              }).toList();
            },
          ),
        ],
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.errorLoadingMatches,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadMatches,
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.retry),
                  ),
                ],
              ),
            );
          }

          if (provider.matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_soccer, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.noMatchesFound,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.tryDifferentLeague,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMatches,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: provider.matches.length,
              itemBuilder: (context, index) {
                final match = provider.matches[index];
                return MatchCard(
                  match: match,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchDetailScreen(match: match),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => const LiveMatchesSheet(),
          );
        },
        child: const Icon(Icons.live_tv),
      ),
    );
  }
}

class LiveMatchesSheet extends StatefulWidget {
  const LiveMatchesSheet({super.key});

  @override
  State<LiveMatchesSheet> createState() => _LiveMatchesSheetState();
}

class _LiveMatchesSheetState extends State<LiveMatchesSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().fetchLiveMatches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(context.l10n.liveMatches, style: Theme.of(context).textTheme.titleLarge),
              IconButton(
                onPressed: () {
                  context.read<MatchProvider>().fetchLiveMatches();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<MatchProvider>(
              builder: (context, provider, child) {
                if (provider.liveMatches.isEmpty) {
                  return Center(child: Text(context.l10n.noMatchesFound));
                }

                return ListView.builder(
                  itemCount: provider.liveMatches.length,
                  itemBuilder: (context, index) {
                    final match = provider.liveMatches[index];
                    return MatchCard(
                      match: match,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MatchDetailScreen(match: match),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
