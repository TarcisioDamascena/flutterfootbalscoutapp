import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/odds.dart';

class OddsApiService {
  /// Fetch odds from The Odds API
  /// Returns real bookmaker odds for a specific match
  Future<Odds?> fetchOddsFromApi({
    required int matchId,
    required String homeTeam,
    required String awayTeam,
    String? leagueName,
  }) async {
    try {
      // Determine the sport key based on league
      String sportKey = _getSportKey(leagueName);

      final url =
          Uri.parse(
            '${ApiConstants.oddsApiBaseUrl}/sports/$sportKey/odds',
          ).replace(
            queryParameters: {
              'apiKey': ApiConstants.oddsApiKey,
              'regions': 'uk,eu', // UK and European bookmakers
              'markets': 'h2h', // Head to head (match winner)
              'oddsFormat': 'decimal',
            },
          );

      final response = await http.get(
        url,
        headers: ApiConstants.oddsApiHeaders,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        // Find the matching game
        for (var game in data) {
          if (_isMatchingGame(game, homeTeam, awayTeam)) {
            return _parseOddsFromGame(game, matchId);
          }
        }

        // No matching game found
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your Odds API key.');
      } else if (response.statusCode == 429) {
        throw Exception(
          'Rate limit exceeded. You have used your monthly quota.',
        );
      } else {
        throw Exception('Failed to fetch odds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching odds from API: $e');
    }
  }

  /// Get the sport key for The Odds API based on league name
  String _getSportKey(String? leagueName) {
    if (leagueName == null) return ApiConstants.oddsApiSoccerKey;

    // Try to find exact match
    if (ApiConstants.oddsApiSportKeys.containsKey(leagueName)) {
      return ApiConstants.oddsApiSportKeys[leagueName]!;
    }

    // Check if league name contains key words
    final lowerLeague = leagueName.toLowerCase();
    if (lowerLeague.contains('premier')) return 'soccer_epl';
    if (lowerLeague.contains('la liga') || lowerLeague.contains('spain'))
      return 'soccer_spain_la_liga';
    if (lowerLeague.contains('serie a') || lowerLeague.contains('italy'))
      return 'soccer_italy_serie_a';
    if (lowerLeague.contains('bundesliga') || lowerLeague.contains('germany'))
      return 'soccer_germany_bundesliga';
    if (lowerLeague.contains('ligue') || lowerLeague.contains('france'))
      return 'soccer_france_ligue_one';
    if (lowerLeague.contains('champions')) return 'soccer_uefa_champs_league';
    if (lowerLeague.contains('europa')) return 'soccer_uefa_europa_league';

    // Default to Premier League
    return ApiConstants.oddsApiSoccerKey;
  }

  /// Check if the game from API matches our teams
  bool _isMatchingGame(
    Map<String, dynamic> game,
    String homeTeam,
    String awayTeam,
  ) {
    final apiHomeTeam = game['home_team']?.toString().toLowerCase() ?? '';
    final apiAwayTeam = game['away_team']?.toString().toLowerCase() ?? '';

    final searchHome = homeTeam.toLowerCase();
    final searchAway = awayTeam.toLowerCase();

    // Exact match
    if (apiHomeTeam == searchHome && apiAwayTeam == searchAway) {
      return true;
    }

    // Partial match (in case of slight name differences)
    if (apiHomeTeam.contains(searchHome.split(' ').first) &&
        apiAwayTeam.contains(searchAway.split(' ').first)) {
      return true;
    }

    return false;
  }

  /// Parse odds from The Odds API game data
  Odds _parseOddsFromGame(Map<String, dynamic> game, int matchId) {
    double homeOdds = 0.0;
    double drawOdds = 0.0;
    double awayOdds = 0.0;

    final bookmakers = game['bookmakers'] as List<dynamic>?;

    if (bookmakers != null && bookmakers.isNotEmpty) {
      // Use the first bookmaker's odds (typically the most popular one)
      final bookmaker = bookmakers[0];
      final markets = bookmaker['markets'] as List<dynamic>?;

      if (markets != null) {
        for (var market in markets) {
          if (market['key'] == 'h2h') {
            final outcomes = market['outcomes'] as List<dynamic>;

            for (var outcome in outcomes) {
              final name = outcome['name'].toString();
              final price = (outcome['price'] as num).toDouble();

              if (name == game['home_team']) {
                homeOdds = price;
              } else if (name == game['away_team']) {
                awayOdds = price;
              } else if (name.toLowerCase() == 'draw') {
                drawOdds = price;
              }
            }
          }
        }
      }
    }

    // Calculate probabilities from odds
    final probabilities = Odds.calculateImpliedProbabilities(
      homeOdds: homeOdds,
      drawOdds: drawOdds,
      awayOdds: awayOdds,
    );

    return Odds(
      matchId: matchId,
      homeWinOdds: homeOdds,
      drawOdds: drawOdds,
      awayWinOdds: awayOdds,
      homeWinProbability: probabilities['home'],
      drawProbability: probabilities['draw'],
      awayWinProbability: probabilities['away'],
      source: 'odds_api',
      lastUpdated: DateTime.now(),
    );
  }

  /// Check available sports (useful for debugging)
  Future<List<String>> getAvailableSports() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.oddsApiBaseUrl}/sports',
      ).replace(queryParameters: {'apiKey': ApiConstants.oddsApiKey});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((sport) => sport['key'].toString()).toList();
      }

      return [];
    } catch (e) {
      return [];
    }
  }

  /// Get remaining API quota
  Future<Map<String, dynamic>?> getApiQuota() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.oddsApiBaseUrl}/sports',
      ).replace(queryParameters: {'apiKey': ApiConstants.oddsApiKey});

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return {
          'requests_remaining': response.headers['x-requests-remaining'],
          'requests_used': response.headers['x-requests-used'],
          'status': 'active',
        };
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
