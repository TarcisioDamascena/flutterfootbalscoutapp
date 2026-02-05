import '../models/match.dart';
import '../models/odds.dart';
import 'odds_api_service.dart';

class OddsService {
  final OddsApiService _oddsApiService = OddsApiService();

  /// Get odds with automatic fallback system:
  /// 1. Try The Odds API first
  /// 2. If fails, calculate custom odds
  Future<Odds> getOddsWithFallback({
    required int matchId,
    required Match match,
    List<Match>? homeTeamRecentMatches,
    List<Match>? awayTeamRecentMatches,
    List<Match>? headToHeadMatches,
  }) async {
    // Try to get odds from The Odds API first
    try {
      final apiOdds = await _oddsApiService.fetchOddsFromApi(
        matchId: matchId,
        homeTeam: match.homeTeam.name,
        awayTeam: match.awayTeam.name,
        leagueName: match.leagueName,
      );

      if (apiOdds != null) {
        print('✅ Using odds from The Odds API');
        return apiOdds;
      }
    } catch (e) {
      print('⚠️ The Odds API failed: $e');
      print('📊 Falling back to custom calculation...');
    }

    // Fallback to custom calculation
    return await calculateOdds(
      matchId: matchId,
      homeTeamId: match.homeTeam.id,
      awayTeamId: match.awayTeam.id,
      homeTeamRecentMatches: homeTeamRecentMatches,
      awayTeamRecentMatches: awayTeamRecentMatches,
      headToHeadMatches: headToHeadMatches,
    );
  }

  /// Calculate odds based on historical data and team statistics
  /// This is a simplified algorithm - you can enhance it with more factors
  Future<Odds> calculateOdds({
    required int matchId,
    required int homeTeamId,
    required int awayTeamId,
    List<Match>? homeTeamRecentMatches,
    List<Match>? awayTeamRecentMatches,
    List<Match>? headToHeadMatches,
  }) async {
    // Calculate team form (recent performance)
    final homeForm = _calculateTeamForm(
      homeTeamRecentMatches ?? [],
      homeTeamId,
    );
    final awayForm = _calculateTeamForm(
      awayTeamRecentMatches ?? [],
      awayTeamId,
    );

    // Calculate head-to-head statistics
    final h2hStats = _calculateH2HStats(
      headToHeadMatches ?? [],
      homeTeamId,
      awayTeamId,
    );

    // Home advantage factor (typically 10-15% advantage)
    const double homeAdvantage = 1.15;

    // Calculate base strengths
    double homeStrength =
        (homeForm['points']! * 0.5 +
            homeForm['goalsScored']! * 0.3 +
            h2hStats['homeWins']! * 0.2) *
        homeAdvantage;

    double awayStrength =
        (awayForm['points']! * 0.5 +
        awayForm['goalsScored']! * 0.3 +
        h2hStats['awayWins']! * 0.2);

    // Normalize strengths
    final totalStrength = homeStrength + awayStrength;
    if (totalStrength > 0) {
      homeStrength = homeStrength / totalStrength;
      awayStrength = awayStrength / totalStrength;
    } else {
      homeStrength = 0.5;
      awayStrength = 0.5;
    }

    // Calculate probabilities
    final homeWinProb = homeStrength * 0.45; // Max 45% for home win
    final awayWinProb = awayStrength * 0.45; // Max 45% for away win
    final drawProb = 1.0 - homeWinProb - awayWinProb;

    // Convert probabilities to decimal odds
    final homeWinOdds = _probabilityToOdds(homeWinProb);
    final drawOdds = _probabilityToOdds(drawProb);
    final awayWinOdds = _probabilityToOdds(awayWinProb);

    return Odds(
      matchId: matchId,
      homeWinOdds: homeWinOdds,
      drawOdds: drawOdds,
      awayWinOdds: awayWinOdds,
      homeWinProbability: homeWinProb * 100,
      drawProbability: drawProb * 100,
      awayWinProbability: awayWinProb * 100,
      source: 'calculated',
      lastUpdated: DateTime.now(),
    );
  }

  /// Calculate team form from recent matches
  Map<String, double> _calculateTeamForm(List<Match> matches, int teamId) {
    if (matches.isEmpty) {
      return {'points': 1.0, 'goalsScored': 1.0, 'goalsConceded': 1.0};
    }

    int points = 0;
    int goalsScored = 0;
    int goalsConceded = 0;

    for (var match in matches) {
      if (!match.isFinished) continue;

      final isHomeTeam = match.homeTeam.id == teamId;
      final teamScore = isHomeTeam ? match.homeScore! : match.awayScore!;
      final opponentScore = isHomeTeam ? match.awayScore! : match.homeScore!;

      // Calculate points
      if (teamScore > opponentScore) {
        points += 3; // Win
      } else if (teamScore == opponentScore) {
        points += 1; // Draw
      }

      goalsScored += teamScore;
      goalsConceded += opponentScore;
    }

    // Normalize values (max points for 5 matches = 15)
    final maxPoints = matches.length * 3;
    final normalizedPoints = maxPoints > 0 ? points / maxPoints : 0.5;
    final normalizedGoalsScored =
        goalsScored / (matches.length > 0 ? matches.length : 1);
    final normalizedGoalsConceded =
        goalsConceded / (matches.length > 0 ? matches.length : 1);

    return {
      'points': normalizedPoints,
      'goalsScored': normalizedGoalsScored / 3.0, // Normalize to ~0-1 range
      'goalsConceded': normalizedGoalsConceded / 3.0,
    };
  }

  /// Calculate head-to-head statistics
  Map<String, double> _calculateH2HStats(
    List<Match> matches,
    int homeTeamId,
    int awayTeamId,
  ) {
    if (matches.isEmpty) {
      return {'homeWins': 0.5, 'awayWins': 0.5, 'draws': 0.5};
    }

    int homeWins = 0;
    int awayWins = 0;
    int draws = 0;

    for (var match in matches) {
      if (!match.isFinished) continue;

      if (match.homeScore! > match.awayScore!) {
        if (match.homeTeam.id == homeTeamId) {
          homeWins++;
        } else {
          awayWins++;
        }
      } else if (match.homeScore! < match.awayScore!) {
        if (match.awayTeam.id == awayTeamId) {
          awayWins++;
        } else {
          homeWins++;
        }
      } else {
        draws++;
      }
    }

    final total = matches.length.toDouble();
    return {
      'homeWins': homeWins / total,
      'awayWins': awayWins / total,
      'draws': draws / total,
    };
  }

  /// Convert probability to decimal odds
  double _probabilityToOdds(double probability) {
    if (probability <= 0 || probability >= 1) {
      return 1.01; // Minimum odds
    }

    // Add margin (bookmaker's edge) of 5%
    const double margin = 1.05;
    final odds = (1 / probability) * margin;

    // Clamp odds to reasonable range
    return odds.clamp(1.01, 50.0);
  }

  /// Check API quota for The Odds API
  Future<Map<String, dynamic>?> checkApiQuota() async {
    return await _oddsApiService.getApiQuota();
  }

  /// Enhanced odds calculation with more factors
  Future<Odds> calculateAdvancedOdds({
    required int matchId,
    required int homeTeamId,
    required int awayTeamId,
    List<Match>? homeTeamRecentMatches,
    List<Match>? awayTeamRecentMatches,
    List<Match>? headToHeadMatches,
    int? homeTeamLeaguePosition,
    int? awayTeamLeaguePosition,
    bool? homeTeamHomeRecord,
    bool? awayTeamAwayRecord,
  }) async {
    // Future enhancement: incorporate league positions and home/away records
    return await calculateOdds(
      matchId: matchId,
      homeTeamId: homeTeamId,
      awayTeamId: awayTeamId,
      homeTeamRecentMatches: homeTeamRecentMatches,
      awayTeamRecentMatches: awayTeamRecentMatches,
      headToHeadMatches: headToHeadMatches,
    );
  }
}
