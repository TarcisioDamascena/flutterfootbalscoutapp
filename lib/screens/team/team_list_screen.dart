import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/team_card.dart';
import 'team_detail_screen.dart';

class TeamListScreen extends StatefulWidget {
  const TeamListScreen({super.key});

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  String _selectedLeague = AppConstants.defaultLeague;
  int _selectedSeason = AppConstants.currentSeason;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeams();
    });
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
        title: const Text('Teams'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedLeague = value;
              });
              _loadTeams();
            },
            itemBuilder: (context) {
              return AppConstants.leagueIds.keys.map((league) {
                return PopupMenuItem<String>(
                  value: league,
                  child: Text(league),
                );
              }).toList();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search teams...',
                prefixIcon: Icon(Icons.search),
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
                  Text('Error loading teams'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadTeams,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final filteredTeams = _searchQuery.isEmpty
              ? provider.teams
              : provider.teams
                    .where(
                      (team) => team.name.toLowerCase().contains(_searchQuery),
                    )
                    .toList();

          if (filteredTeams.isEmpty) {
            return const Center(child: Text('No teams found'));
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
                      MaterialPageRoute(
                        builder: (context) => TeamDetailScreen(team: team),
                      ),
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
