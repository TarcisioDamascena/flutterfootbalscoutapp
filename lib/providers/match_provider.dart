import 'package:flutter/foundation.dart';
import '../models/match.dart';
import '../services/football_api_service.dart';
import '../services/database_service.dart';
import '../core/services/service_locator.dart';

class MatchProvider extends ChangeNotifier {
  final FootballApiService _apiService = getIt<FootballApiService>();
  final DatabaseService _dbService = getIt<DatabaseService>();

  List<Match> _matches = [];
  List<Match> _liveMatches = [];
  bool _isLoading = false;
  String? _error;

  List<Match> get matches => _matches;
  List<Match> get liveMatches => _liveMatches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMatches({
    required String competitionCode,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _apiService.fetchMatches(
        competitionCode: competitionCode,
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      // Save to database
      for (var match in _matches) {
        await _dbService.insertMatch(match);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      // Try to load from database if API fails
      final cachedMatches = await _dbService.getMatchesByCompetition(
        competitionCode,
      );
      _matches = cachedMatches.map((m) => Match.fromJson(m)).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllMatches({
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _matches = await _apiService.fetchAllMatches(
        status: status,
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      // Save to database
      for (var match in _matches) {
        await _dbService.insertMatch(match);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLiveMatches() async {
    try {
      // Football-Data.org uses status=IN_PLAY for live matches
      _liveMatches = await _apiService.fetchAllMatches(status: 'IN_PLAY');
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Match>> fetchHeadToHead({
    required int team1Id,
    required int team2Id,
    int limit = 10,
  }) async {
    try {
      return await _apiService.fetchHeadToHead(
        team1Id: team1Id,
        team2Id: team2Id,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Match>> fetchTeamMatches({
    required int teamId,
    String? status,
    int? limit,
  }) async {
    try {
      return await _apiService.fetchTeamMatches(
        teamId: teamId,
        status: status,
        limit: limit,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  List<Match> getUpcomingMatches() {
    return _matches.where((match) => match.isScheduled).toList();
  }

  List<Match> getFinishedMatches() {
    return _matches.where((match) => match.isFinished).toList();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
