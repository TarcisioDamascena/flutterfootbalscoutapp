import 'package:flutter/foundation.dart';
import '../models/odds.dart';
import '../models/match.dart';
import '../services/odds_service.dart';
import '../services/database_service.dart';
import '../core/services/service_locator.dart';

class OddsProvider extends ChangeNotifier {
  final OddsService _oddsService = getIt<OddsService>();
  final DatabaseService _dbService = getIt<DatabaseService>();

  Map<int, Odds> _oddsCache = {};
  bool _isCalculating = false;
  String? _error;

  Map<int, Odds> get oddsCache => _oddsCache;
  bool get isCalculating => _isCalculating;
  String? get error => _error;

  Future<Odds?> calculateMatchOdds({
    required Match match,
    List<Match>? homeTeamRecentMatches,
    List<Match>? awayTeamRecentMatches,
    List<Match>? headToHeadMatches,
  }) async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      // Check if odds already exist in database
      Odds? existingOdds = await _dbService.getOddsByMatchId(match.id);

      // If odds exist and are recent (less than 24 hours old), use them
      if (existingOdds != null &&
          DateTime.now().difference(existingOdds.lastUpdated).inHours < 24) {
        _oddsCache[match.id] = existingOdds;
        _isCalculating = false;
        notifyListeners();
        return existingOdds;
      }

      // Calculate new odds
      final odds = await _oddsService.calculateOdds(
        matchId: match.id,
        homeTeamId: match.homeTeam.id,
        awayTeamId: match.awayTeam.id,
        homeTeamRecentMatches: homeTeamRecentMatches,
        awayTeamRecentMatches: awayTeamRecentMatches,
        headToHeadMatches: headToHeadMatches,
      );

      // Save to database
      await _dbService.insertOdds(odds);

      // Update cache
      _oddsCache[match.id] = odds;
      _error = null;

      return odds;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<Odds?> getOddsForMatch(int matchId) async {
    // Check cache first
    if (_oddsCache.containsKey(matchId)) {
      return _oddsCache[matchId];
    }

    // Check database
    try {
      final odds = await _dbService.getOddsByMatchId(matchId);
      if (odds != null) {
        _oddsCache[matchId] = odds;
        notifyListeners();
      }
      return odds;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearCache() {
    _oddsCache.clear();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String getOddsQuality(Odds odds) {
    if (odds.source == 'api') return 'Official';

    // If we have enough data, quality is good
    if (odds.homeWinProbability != null &&
        odds.drawProbability != null &&
        odds.awayWinProbability != null) {
      return 'Calculated';
    }

    return 'Estimated';
  }
}
