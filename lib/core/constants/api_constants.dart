class ApiConstants {
  // Base URLs
  static const String footballDataBaseUrl = 'https://api.football-data.org/v4';

  // Football-Data.org endpoints
  static const String competitionsEndpoint = '/competitions';
  static const String teamsEndpoint = '/teams';
  static const String matchesEndpoint = '/matches';
  static const String standingsEndpoint = '/standings';

  // API Key - Football-Data.org
  static const String footballDataApiKey = '34143df3a2b24ba5b74161d7f65099f0';

  // Request headers for Football-Data.org
  static Map<String, String> get footballDataHeaders => {
    'X-Auth-Token': footballDataApiKey,
  };

  // Competition codes
  static const Map<String, String> competitionCodes = {
    'World Cup': 'WC',
    'Champions League': 'CL',
    'Bundesliga': 'BL1',
    'Eredivisie': 'DED',
    'Brasileirão Série A': 'BSA',
    'La Liga': 'PD',
    'Ligue 1': 'FL1',
    'Championship': 'ELC',
    'Primeira Liga': 'PPL',
    'Euro Championship': 'EC',
    'Serie A': 'SA',
    'Premier League': 'PL',
  };

  // Pagination
  static const int itemsPerPage = 20;

  // Cache Duration (in hours)
  static const int teamsCacheDuration = 24;
  static const int fixturesCacheDuration = 1;
  static const int standingsCacheDuration = 6;
}
