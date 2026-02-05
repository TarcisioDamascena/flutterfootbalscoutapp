class ApiConstants {
  // Base URLs
  static const String apiFootballBaseUrl = 'https://v3.football.api-sports.io';
  static const String customBackendUrl =
      'YOUR_BACKEND_URL'; // Replace with your backend URL
  static const String oddsApiBaseUrl = 'https://api.the-odds-api.com/v4';

  // API Football endpoints
  static const String teamsEndpoint = '/teams';
  static const String fixturesEndpoint = '/fixtures';
  static const String standingsEndpoint = '/standings';
  static const String oddsEndpoint = '/odds';
  static const String h2hEndpoint = '/fixtures/headtohead';
  static const String statisticsEndpoint = '/fixtures/statistics';
  static const String playersEndpoint = '/players';

  // The Odds API endpoints
  static const String oddsApiSportsEndpoint = '/sports';
  static const String oddsApiOddsEndpoint = '/sports/{sport}/odds';

  // API Keys (Replace with your actual keys)
  static const String apiFootballKey = 'ee6779935d2cc11ef9113199d1313e02';
  static const String oddsApiKey = '708857d249f407668cc34532a73f5f3a';

  // Request headers
  static Map<String, String> get apiFootballHeaders => {
    'x-rapidapi-key': apiFootballKey,
    'x-rapidapi-host': 'v3.football.api-sports.io',
  };

  static Map<String, String> get oddsApiHeaders => {
    'Content-Type': 'application/json',
  };

  // The Odds API Sport Keys
  static const String oddsApiSoccerKey = 'soccer_epl';
  static const Map<String, String> oddsApiSportKeys = {
    'Premier League': 'soccer_epl',
    'La Liga': 'soccer_spain_la_liga',
    'Serie A': 'soccer_italy_serie_a',
    'Bundesliga': 'soccer_germany_bundesliga',
    'Ligue 1': 'soccer_france_ligue_one',
    'Champions League': 'soccer_uefa_champs_league',
    'Europa League': 'soccer_uefa_europa_league',
  };

  // Pagination
  static const int defaultPageSize = 20;

  // Cache durations (in hours)
  static const int teamsCacheDuration = 24;
  static const int fixturesCacheDuration = 1;
  static const int standingsCacheDuration = 6;
  static const int oddsCacheDuration = 2; // Odds change frequently
}
