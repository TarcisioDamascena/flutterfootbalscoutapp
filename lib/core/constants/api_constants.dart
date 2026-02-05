class ApiConstants {
  // Base URLs
  static const String apiFootballBaseUrl = 'https://v3.football.api-sports.io/';
  static const String backendUrl =
      "BACKEND_URL_HERE"; // Replace with backend URL

  // API football endpoints
  static const String leaguesEndpoint = 'leagues';
  static const String teamsEndpoint = 'teams';
  static const String fixturesEndpoint = 'fixtures';
  static const String standingsEndpoint = 'standings';
  static const String oddsEndpoint = 'odds';
  static const String h2hEndpoint = 'fixtures/headtohead/';
  static const String statisticsEndpoint = 'fixtures/statistics/';
  static const String playersEndpoint = 'players';

  // API Keys
  static const String apiFootballKey = 'ee6779935d2cc11ef9113199d1313e02';

  // Request Headers
  static Map<String, String> get apiFootballHeaders => {
    'x-rapidapo-key': apiFootballKey,
    'x-apisports-host': 'v3.football.api-sports.io',
  };

  // Pagination
  static const int itemsPerPage = 20;

  // Cache Duration (in hours)
  static const int teamsCacheDuration = 24;
  static const int fixturesCacheDuration = 1;
  static const int standingsCacheDuration = 6;
}
