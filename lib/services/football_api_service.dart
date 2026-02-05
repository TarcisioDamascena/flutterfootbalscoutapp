import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/team.dart';
import '../models/match.dart';

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
}
