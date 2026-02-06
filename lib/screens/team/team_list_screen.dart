import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/team_provider.dart';
import '../../widgets/options_menu_button.dart';
import '../../widgets/team_card.dart';
import 'team_detail_screen.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  String _selectedLeague = AppConstants.defaultLeague;
  late int _selectedSeason;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedSeason = _currentSeason();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeams();
    });
  }

  int _currentSeason() {
    final now = DateTime.now();
    return now.month >= 7 ? now.year : now.year - 1;
  }

  Future<void> _loadTeams() async {
    final leagueId = AppConstants.leagueIds[_selectedLeague] ?? 39;
    await context.read<TeamProvider>().fetchTeams(
      leagueId: leagueId,
      season: _selectedSeason,
    );
    await context.read<TeamProvider>().loadFavoriteTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.teams),
        actions: [
          const OptionsMenuButton(),
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedLeague = value;
                _selectedSeason = _currentSeason();
              });
              _loadTeams();
            },
            itemBuilder: (context) {
              return AppConstants.leagueIds.keys.map((league) {
                return PopupMenuItem<String>(value: league, child: Text(league));
              }).toList();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: context.l10n.searchTeams,
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(context.l10n.errorLoadingTeams),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadTeams,
                    child: Text(context.l10n.retry),
                  ),
                ],
              ),
            );
          }

          final filteredTeams = _searchQuery.isEmpty
              ? provider.teams
              : provider.teams
                    .where((team) => team.name.toLowerCase().contains(_searchQuery))
                    .toList();

          if (filteredTeams.isEmpty) {
            return Center(child: Text(context.l10n.noTeamsFound));
          }

          return RefreshIndicator(
            onRefresh: _loadTeams,
            child: ListView.builder(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              itemCount: filteredTeams.length,
              itemBuilder: (context, index) {
                final team = filteredTeams[index];
                return TeamCard(
                  team: team,
                  isFavorite: provider.isFavorite(team.id),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TeamDetailScreen(team: team)),
                    );
                  },
                  onFavoriteToggle: () {
                    provider.toggleFavorite(team.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
