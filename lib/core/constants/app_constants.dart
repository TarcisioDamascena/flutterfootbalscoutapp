class AppConstants {
  // App information
  static const String appName = "Football Scout";
  static const String appVersion = "1.0.0";

  // Database
  static const String databaseName = "football_scout.db";
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFavoriteTeams = 'favorite_teams';
  static const String keySelectedLeague = 'selected_league';
  static const String keyLastSync = 'last_sync';

  // League IDs (API-Football)
  static const Map<String, int> leagueIds = {
    'Premier League': 39,
    'La Liga': 140,
    'Serie A': 135,
    'Bundesliga': 78,
    'Ligue 1': 61,
    'Champions League': 2,
    'Europa League': 3,
    'World Cup': 1,
    'Brasileirão Serie A': 71,
  };

  // Default Settings
  static const String defaultLeague = 'Premier League';
  static const int defaultSeason = 2024;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}
