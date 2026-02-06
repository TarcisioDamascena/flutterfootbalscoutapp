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

  List<Team> get teams => _teams;
  List<int> get favoriteTeamIds => _favoriteTeamIds;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Team> get favoriteTeams {
    return _teams.where((team) => _favoriteTeamIds.contains(team.id)).toList();
  }

  Future<void> fetchTeams({required String competitionCode}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _teams = await _apiService.fetchTeams(competitionCode: competitionCode);

      // Save to database
      for (var team in _teams) {
        await _dbService.insertTeam(team);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      // Try to load from database if API fails
      _teams = await _dbService.getAllTeams();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
