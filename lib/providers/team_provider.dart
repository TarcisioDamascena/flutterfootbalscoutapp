import 'package:flutter/foundation.dart';
import '../models/team.dart';
import '../services/football_api_service.dart';
import '../services/database_service.dart';
import '../core/services/service_locator.dart';

class TeamProvider extends ChangeNotifier {
  final FootballApiService _apiService = getIt<FootballApiService>();
  final DatabaseService _dbService = getIt<DatabaseService>();

  List<Team> _teams = [];
  List<int> _favoriteTeamIds = [];
  bool _isLoading = false;
  String? _error;
  int? _activeSeason;

  List<Team> get teams => _teams;
  List<int> get favoriteTeamIds => _favoriteTeamIds;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get activeSeason => _activeSeason;

  List<Team> get favoriteTeams {
    return _teams.where((team) => _favoriteTeamIds.contains(team.id)).toList();
  }

  Future<void> fetchTeams({required int leagueId, required int season}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final teamsResult = await _fetchTeamsWithSeasonFallback(
        leagueId: leagueId,
        season: season,
      );
      _activeSeason = teamsResult.key;
      _teams = teamsResult.value;

      // Save to database
      for (var team in _teams) {
        await _dbService.insertTeam(team);
      }

      _error = null;
    } catch (e) {
      _activeSeason = null;
      _error = e.toString();
      // Keep league-specific results only to avoid showing stale teams from other leagues
      _teams = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<MapEntry<int?, List<Team>>> _fetchTeamsWithSeasonFallback({
    required int leagueId,
    required int season,
  }) async {
    final currentYear = DateTime.now().year;
    final candidateSeasons = <int>{
      season,
      currentYear,
      currentYear - 1,
      season + 1,
      season - 1,
    }.where((year) => year > 0);

    Object? lastError;

    for (final candidateSeason in candidateSeasons) {
      try {
        final teams = await _apiService.fetchTeams(
          leagueId: leagueId,
          season: candidateSeason,
        );

        if (teams.isNotEmpty) {
          return MapEntry(candidateSeason, teams);
        }
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw Exception(lastError.toString());
    }

    return const MapEntry(null, <Team>[]);
  }

  Future<Team?> fetchTeamById(int teamId) async {
    try {
      // First check database
      Team? team = await _dbService.getTeamById(teamId);

      if (team == null) {
        // Fetch from API if not in database
        team = await _apiService.fetchTeamById(teamId);
        if (team != null) {
          await _dbService.insertTeam(team);
        }
      }

      return team;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> loadFavoriteTeams() async {
    try {
      _favoriteTeamIds = await _dbService.getFavoriteTeamIds();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(int teamId) async {
    try {
      if (_favoriteTeamIds.contains(teamId)) {
        await _dbService.removeFavoriteTeam(teamId);
        _favoriteTeamIds.remove(teamId);
      } else {
        await _dbService.addFavoriteTeam(teamId);
        _favoriteTeamIds.add(teamId);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  bool isFavorite(int teamId) {
    return _favoriteTeamIds.contains(teamId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
