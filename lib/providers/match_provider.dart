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
  int? _activeSeason;

  List<Match> get matches => _matches;
  List<Match> get liveMatches => _liveMatches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get activeSeason => _activeSeason;

  Future<void> fetchFixtures({
    required int leagueId,
    required int season,
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fixtureResult = await _fetchFixturesWithSeasonFallback(
        leagueId: leagueId,
        season: season,
        status: status,
        from: from,
        to: to,
      );

      _activeSeason = fixtureResult.key;
      _matches = fixtureResult.value;

      // Save to database
      for (var match in _matches) {
        await _dbService.insertMatch(match);
      }

      _error = null;
    } catch (e) {
      _activeSeason = null;
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<MapEntry<int?, List<Match>>> _fetchFixturesWithSeasonFallback({
    required int leagueId,
    required int season,
    String? status,
    DateTime? from,
    DateTime? to,
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
        final fixtures = await _apiService.fetchFixtures(
          leagueId: leagueId,
          season: candidateSeason,
          status: status,
          from: from,
          to: to,
        );

        if (fixtures.isNotEmpty) {
          return MapEntry(candidateSeason, fixtures);
        }
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw Exception(lastError.toString());
    }

    return const MapEntry(null, <Match>[]);
  }

  Future<void> fetchLiveMatches() async {
    try {
      _liveMatches = await _apiService.fetchLiveMatches();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<List<Match>> fetchHeadToHead({
    required int team1Id,
    required int team2Id,
    int? last,
  }) async {
    try {
      return await _apiService.fetchHeadToHead(
        team1Id: team1Id,
        team2Id: team2Id,
        last: last,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<List<Match>> fetchTeamMatches({
    required int teamId,
    required int season,
    int? last,
  }) async {
    try {
      return await _apiService.fetchTeamMatches(
        teamId: teamId,
        season: season,
        last: last,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchMatchStatistics(int fixtureId) async {
    try {
      return await _apiService.fetchMatchStatistics(fixtureId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
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
