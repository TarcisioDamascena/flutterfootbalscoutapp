import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [Locale('en'), Locale('pt', 'BR')];

  static const _localizedValues = <String, Map<String, String>>{
    'en': {
      'appTitle': 'Football Scout',
      'matches': 'Matches',
      'teams': 'Teams',
      'favorites': 'Favorites',
      'favoriteTeams': 'Favorite Teams',
      'settings': 'Settings',
      'theme': 'Theme',
      'language': 'Language',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'english': 'English',
      'portugueseBrazil': 'Portuguese (Brazil)',
      'errorLoadingMatches': 'Error loading matches',
      'errorLoadingTeams': 'Error loading teams',
      'retry': 'Retry',
      'noMatchesFound': 'No matches found',
      'tryDifferentLeague': 'Try selecting a different league',
      'searchTeams': 'Search teams...',
      'noTeamsFound': 'No teams found',
      'noFavoriteTeamsYet': 'No favorite teams yet',
      'addFavoritesHint': 'Add teams to your favorites from the Teams tab',
      'liveMatches': 'Live Matches',
      'matchDetails': 'Match Details',
      'matchInformation': 'Match Information',
      'league': 'League',
      'round': 'Round',
      'status': 'Status',
      'referee': 'Referee',
      'na': 'N/A',
      'vs': 'VS',
      'live': 'LIVE',
    },
    'pt': {
      'appTitle': 'Olheiro de Futebol',
      'matches': 'Partidas',
      'teams': 'Times',
      'favorites': 'Favoritos',
      'favoriteTeams': 'Times Favoritos',
      'settings': 'Configurações',
      'theme': 'Tema',
      'language': 'Idioma',
      'system': 'Sistema',
      'light': 'Claro',
      'dark': 'Escuro',
      'english': 'Inglês',
      'portugueseBrazil': 'Português (Brasil)',
      'errorLoadingMatches': 'Erro ao carregar partidas',
      'errorLoadingTeams': 'Erro ao carregar times',
      'retry': 'Tentar novamente',
      'noMatchesFound': 'Nenhuma partida encontrada',
      'tryDifferentLeague': 'Tente selecionar outra liga',
      'searchTeams': 'Buscar times...',
      'noTeamsFound': 'Nenhum time encontrado',
      'noFavoriteTeamsYet': 'Nenhum time favorito ainda',
      'addFavoritesHint': 'Adicione times aos favoritos na aba Times',
      'liveMatches': 'Partidas ao vivo',
      'matchDetails': 'Detalhes da Partida',
      'matchInformation': 'Informações da Partida',
      'league': 'Liga',
      'round': 'Rodada',
      'status': 'Status',
      'referee': 'Árbitro',
      'na': 'N/A',
      'vs': 'VS',
      'live': 'AO VIVO',
    },
  };

  String _text(String key) =>
      _localizedValues[locale.languageCode]?[key] ?? _localizedValues['en']![key]!;

  String get appTitle => _text('appTitle');
  String get matches => _text('matches');
  String get teams => _text('teams');
  String get favorites => _text('favorites');
  String get favoriteTeams => _text('favoriteTeams');
  String get settings => _text('settings');
  String get theme => _text('theme');
  String get language => _text('language');
  String get system => _text('system');
  String get light => _text('light');
  String get dark => _text('dark');
  String get english => _text('english');
  String get portugueseBrazil => _text('portugueseBrazil');
  String get errorLoadingMatches => _text('errorLoadingMatches');
  String get errorLoadingTeams => _text('errorLoadingTeams');
  String get retry => _text('retry');
  String get noMatchesFound => _text('noMatchesFound');
  String get tryDifferentLeague => _text('tryDifferentLeague');
  String get searchTeams => _text('searchTeams');
  String get noTeamsFound => _text('noTeamsFound');
  String get noFavoriteTeamsYet => _text('noFavoriteTeamsYet');
  String get addFavoritesHint => _text('addFavoritesHint');
  String get liveMatches => _text('liveMatches');
  String get matchDetails => _text('matchDetails');
  String get matchInformation => _text('matchInformation');
  String get league => _text('league');
  String get round => _text('round');
  String get status => _text('status');
  String get referee => _text('referee');
  String get na => _text('na');
  String get vs => _text('vs');
  String get live => _text('live');

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'No AppLocalizations found in context');
    return value!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
