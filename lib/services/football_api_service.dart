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
    final response = await _get(
      '${ApiConstants.apiFootballBaseUrl}${ApiConstants.teamsEndpoint}?league=$leagueId&season=$season',
    );

    final data = _decodeResponseBody(response, endpoint: 'teams');
    final List<dynamic> teamsJson = data['response'] ?? [];

    return teamsJson.map((json) => Team.fromJson(json['team'])).toList();
  }

  Future<Team?> fetchTeamById(int teamId) async {
    final response = await _get(
      '${ApiConstants.apiFootballBaseUrl}${ApiConstants.teamsEndpoint}?id=$teamId',
    );

    final data = _decodeResponseBody(response, endpoint: 'team by id');
    final List<dynamic> teamsJson = data['response'] ?? [];

    if (teamsJson.isNotEmpty) {
      return Team.fromJson(teamsJson[0]['team']);
    }

    return null;
  }

  Future<List<Match>> fetchFixtures({
    required int leagueId,
    required int season,
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    var url =
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.fixturesEndpoint}?league=$leagueId&season=$season';

    if (status != null) url += '&status=$status';
    if (from != null) url += '&from=${from.toIso8601String().split('T')[0]}';
    if (to != null) url += '&to=${to.toIso8601String().split('T')[0]}';

    final response = await _get(url);
    final data = _decodeResponseBody(response, endpoint: 'fixtures');
    final List<dynamic> fixturesJson = data['response'] ?? [];

    return fixturesJson.map((json) => Match.fromJson(json)).toList();
  }

  Future<List<Match>> fetchLiveMatches() async {
    final response = await _get(
      '${ApiConstants.apiFootballBaseUrl}${ApiConstants.fixturesEndpoint}?live=all',
    );

    final data = _decodeResponseBody(response, endpoint: 'live matches');
    final List<dynamic> fixturesJson = data['response'] ?? [];

    return fixturesJson.map((json) => Match.fromJson(json)).toList();
  }

  Future<List<Match>> fetchHeadToHead({
    required int team1Id,
    required int team2Id,
    int? last,
  }) async {
    var url =
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.h2hEndpoint}?h2h=$team1Id-$team2Id';

    if (last != null) url += '&last=$last';

    final response = await _get(url);
    final data = _decodeResponseBody(response, endpoint: 'head-to-head');
    final List<dynamic> fixturesJson = data['response'] ?? [];

    return fixturesJson.map((json) => Match.fromJson(json)).toList();
  }

  Future<Map<String, dynamic>> fetchMatchStatistics(int fixtureId) async {
    final response = await _get(
      '${ApiConstants.apiFootballBaseUrl}${ApiConstants.statisticsEndpoint}?fixture=$fixtureId',
    );

    final data = _decodeResponseBody(response, endpoint: 'match statistics');
    final responseList = data['response'];

    if (responseList is List && responseList.isNotEmpty) {
      return responseList.first as Map<String, dynamic>;
    }

    return {};
  }

  Future<List<Match>> fetchTeamMatches({
    required int teamId,
    required int season,
    int? last,
  }) async {
    var url =
        '${ApiConstants.apiFootballBaseUrl}${ApiConstants.fixturesEndpoint}?team=$teamId&season=$season';

    if (last != null) url += '&last=$last';

    final response = await _get(url);
    final data = _decodeResponseBody(response, endpoint: 'team matches');
    final List<dynamic> fixturesJson = data['response'] ?? [];

    return fixturesJson.map((json) => Match.fromJson(json)).toList();
  }

  Future<http.Response> _get(String url) async {
    final uri = Uri.parse(url);

    final primaryResponse = await http.get(
      uri,
      headers: ApiConstants.apiFootballHeaders,
    );

    if (primaryResponse.statusCode == 401 || primaryResponse.statusCode == 403) {
      final fallbackResponse = await http.get(
        uri,
        headers: ApiConstants.apiFootballRapidApiHeaders,
      );

      if (fallbackResponse.statusCode < 400) {
        return fallbackResponse;
      }
    }

    return primaryResponse;
  }

  Map<String, dynamic> _decodeResponseBody(
    http.Response response, {
    required String endpoint,
  }) {
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load $endpoint: ${response.statusCode} ${response.reasonPhrase ?? ''}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final errors = data['errors'];

    if (errors is List && errors.isNotEmpty) {
      throw Exception('API error loading $endpoint: ${errors.join(', ')}');
    }

    if (errors is Map && errors.isNotEmpty) {
      throw Exception('API error loading $endpoint: ${errors.values.join(', ')}');
    }

    return data;
  }
}
