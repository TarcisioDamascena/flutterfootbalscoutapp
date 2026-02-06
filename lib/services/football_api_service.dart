import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../models/team.dart';
import '../models/match.dart';

class FootballApiService {
  /// Fetch all available competitions
  Future<List<Map<String, dynamic>>> fetchCompetitions() async {
    try {
      final url = Uri.parse(
        '${ApiConstants.footballDataBaseUrl}${ApiConstants.competitionsEndpoint}',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> competitions = data['competitions'] ?? [];
        return competitions.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load competitions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching competitions: $e');
    }
  }

  /// Fetch teams from a specific competition
  Future<List<Team>> fetchTeams({required String competitionCode}) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.footballDataBaseUrl}${ApiConstants.competitionsEndpoint}/$competitionCode${ApiConstants.teamsEndpoint}',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> teamsJson = data['teams'] ?? [];

        return teamsJson.map((json) => Team.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        throw Exception(
          'API rate limit exceeded. Please try again in a minute.',
        );
      } else {
        throw Exception('Failed to load teams: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching teams: $e');
    }
  }

  /// Fetch team by ID
  Future<Team?> fetchTeamById(int teamId) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.footballDataBaseUrl}${ApiConstants.teamsEndpoint}/$teamId',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Team.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching team: $e');
    }
  }

  /// Fetch matches for a specific competition
  Future<List<Match>> fetchMatches({
    required String competitionCode,
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      var url =
          '${ApiConstants.footballDataBaseUrl}${ApiConstants.competitionsEndpoint}/$competitionCode${ApiConstants.matchesEndpoint}';

      // Add query parameters
      List<String> queryParams = [];
      if (status != null) queryParams.add('status=$status');
      if (dateFrom != null)
        queryParams.add('dateFrom=${dateFrom.toIso8601String().split('T')[0]}');
      if (dateTo != null)
        queryParams.add('dateTo=${dateTo.toIso8601String().split('T')[0]}');

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchesJson = data['matches'] ?? [];

        return matchesJson.map((json) => Match.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        throw Exception(
          'API rate limit exceeded. Please try again in a minute.',
        );
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  /// Fetch all matches (across all competitions) - useful for "today's matches"
  Future<List<Match>> fetchAllMatches({
    String? status,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      var url =
          '${ApiConstants.footballDataBaseUrl}${ApiConstants.matchesEndpoint}';

      // Add query parameters
      List<String> queryParams = [];
      if (status != null) queryParams.add('status=$status');
      if (dateFrom != null)
        queryParams.add('dateFrom=${dateFrom.toIso8601String().split('T')[0]}');
      if (dateTo != null)
        queryParams.add('dateTo=${dateTo.toIso8601String().split('T')[0]}');

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchesJson = data['matches'] ?? [];

        return matchesJson.map((json) => Match.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        throw Exception(
          'API rate limit exceeded. Please try again in a minute.',
        );
      } else {
        throw Exception('Failed to load matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching matches: $e');
    }
  }

  /// Fetch head-to-head matches between two teams
  Future<List<Match>> fetchHeadToHead({
    required int team1Id,
    required int team2Id,
    int limit = 10,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.footballDataBaseUrl}${ApiConstants.matchesEndpoint}?limit=$limit',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchesJson = data['matches'] ?? [];

        // Filter matches that include both teams
        final h2hMatches = matchesJson.where((match) {
          final homeId = match['homeTeam']?['id'];
          final awayId = match['awayTeam']?['id'];
          return (homeId == team1Id && awayId == team2Id) ||
              (homeId == team2Id && awayId == team1Id);
        }).toList();

        return h2hMatches.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load H2H: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching H2H: $e');
    }
  }

  /// Fetch matches for a specific team
  Future<List<Match>> fetchTeamMatches({
    required int teamId,
    String? status,
    int? limit,
  }) async {
    try {
      var url =
          '${ApiConstants.footballDataBaseUrl}${ApiConstants.teamsEndpoint}/$teamId${ApiConstants.matchesEndpoint}';

      List<String> queryParams = [];
      if (status != null) queryParams.add('status=$status');
      if (limit != null) queryParams.add('limit=$limit');

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> matchesJson = data['matches'] ?? [];

        return matchesJson.map((json) => Match.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load team matches: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching team matches: $e');
    }
  }

  /// Fetch standings for a competition
  Future<Map<String, dynamic>> fetchStandings({
    required String competitionCode,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.footballDataBaseUrl}${ApiConstants.competitionsEndpoint}/$competitionCode${ApiConstants.standingsEndpoint}',
      );

      final response = await http.get(
        url,
        headers: ApiConstants.footballDataHeaders,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load standings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching standings: $e');
    }
  }
}
