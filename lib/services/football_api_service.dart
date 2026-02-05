import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/team.dart';
import '../models/match.dart';
import '../models/odds.dart';

class FootballApiService {
  Future<List<Team>> fetchTeams({
    required int leagueId,
    required int season,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.teamsEndpoint}?league=$leagueId&season=$season',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> teamsJson = data['response'] ?? [];

        return teamsJson.map((json) => Team.fromJson(json['team'])).toList();
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }

  Future<Team?> fetchTeamById(int teamId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.teamsEndpoint}?id=$teamId',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> teamsJson = data['response'] ?? [];

        if (teamsJson.isNotEmpty) {
          return Team.fromJson(teamsJson[0]['team']);
        }
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching team: $e');
    }
  }

  Future<List<Match>> fetchFixtures({
    required int leagueId,
    required int season,
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      var url =
          '${ApiConstants.apiFootballBaseUrl}${ApiConstants.fixturesEndpoint}?league=$leagueId&season=$season';

      if (status != null) url += '&status=$status';
      if (from != null) url += '&from=${from.toIso8601String().split('T')[0]}';
      if (to != null) url += '&to=${to.toIso8601String().split('T')[0]}';

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fixturesJson = data['response'] ?? [];

        return fixturesJson.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load fixtures: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching fixtures: $e');
    }
  }

  Future<List<Match>> fetchLiveMatches() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.fixturesEndpoint}?live=all',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fixturesJson = data['response'] ?? [];

        return fixturesJson.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load live matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching live matches: $e');
    }
  }

  Future<List<Match>> fetchHeadToHead({
    required int team1Id,
    required int team2Id,
    int? last,
  }) async {
    try {
      var url =
          '${ApiConstants.apiFootballBaseUrl}${ApiConstants.h2hEndpoint}?h2h=$team1Id-$team2Id';

      if (last != null) url += '&last=$last';

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fixturesJson = data['response'] ?? [];

        return fixturesJson.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load H2H: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching H2H: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMatchStatistics(int fixtureId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.statisticsEndpoint}?fixture=$fixtureId',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? {};
      } else {
        throw Exception('Failed to load statistics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching statistics: $e');
    }
  }

  Future<List<Match>> fetchTeamMatches({
    required int teamId,
    required int season,
    int? last,
  }) async {
    try {
      var url =
          '${ApiConstants.apiFootballBaseUrl}${ApiConstants.fixturesEndpoint}?team=$teamId&season=$season';

      if (last != null) url += '&last=$last';

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fixturesJson = data['response'] ?? [];

        return fixturesJson.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load team matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching team matches: $e');
    }
  }

  Future<Odds?> fetchMatchOdds({required int fixtureId}) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.oddsEndpoint}?fixture=$fixtureId',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.apiFootballHeaders,
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);
      final List<dynamic> oddsResponse = data['response'] ?? [];
      if (oddsResponse.isEmpty) return null;

      for (final fixtureOdds in oddsResponse) {
        final List<dynamic> bookmakers = fixtureOdds['bookmakers'] ?? [];
        for (final bookmaker in bookmakers) {
          final List<dynamic> bets = bookmaker['bets'] ?? [];
          for (final bet in bets) {
            final String betName = (bet['name'] ?? '').toString().toLowerCase();
            if (betName != 'match winner') continue;

            final List<dynamic> values = bet['values'] ?? [];
            double? homeWinOdds;
            double? drawOdds;
            double? awayWinOdds;

            for (final value in values) {
              final outcome = (value['value'] ?? '').toString().toLowerCase();
              final odd = double.tryParse((value['odd'] ?? '').toString());
              if (odd == null) continue;

              if (outcome == 'home') {
                homeWinOdds = odd;
              } else if (outcome == 'draw') {
                drawOdds = odd;
              } else if (outcome == 'away') {
                awayWinOdds = odd;
              }
            }

            if (homeWinOdds != null && drawOdds != null && awayWinOdds != null) {
              final homeProb = _oddsToProbability(homeWinOdds);
              final drawProb = _oddsToProbability(drawOdds);
              final awayProb = _oddsToProbability(awayWinOdds);

              return Odds(
                matchId: fixtureId,
                homeWinOdds: homeWinOdds,
                drawOdds: drawOdds,
                awayWinOdds: awayWinOdds,
                homeWinProbability: homeProb,
                drawProbability: drawProb,
                awayWinProbability: awayProb,
                source: 'api',
                lastUpdated: DateTime.now(),
              );
            }
          }
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  double _oddsToProbability(double odd) {
    if (odd <= 0) return 0;
    return (1 / odd) * 100;
  }

}
