class AppConstants {
  // App Info
  static const String appName = 'Football Scout';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'football_scout.db';
  static const int databaseVersion = 1;

  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLocale = 'locale';
  static const String keyFavoriteTeams = 'favorite_teams';
  static const String keySelectedLeague = 'selected_league';
  static const String keyLastSync = 'last_sync';

  // Competition Codes (Football-Data.org Free Tier)
  static const Map<String, String> competitionCodes = {
    'Premier League': 'PL',
    'La Liga': 'PD',
    'Serie A': 'SA',
    'Bundesliga': 'BL1',
    'Ligue 1': 'FL1',
    'Champions League': 'CL',
    'Eredivisie': 'DED',
    'Championship': 'ELC',
    'Primeira Liga': 'PPL',
    'Brasileirão Série A': 'BSA',
    'World Cup': 'WC',
    'Euro Championship': 'EC',
  };

  // Default Settings
  static const String defaultCompetition = 'Premier League';
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
