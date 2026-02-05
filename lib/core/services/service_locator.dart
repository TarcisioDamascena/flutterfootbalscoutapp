import 'package:get_it/get_it.dart';
import 'package:flutter/foundation.dart';

import '../../services/database_service.dart';
import '../../services/football_api_service.dart';
import '../../services/odds_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<FootballApiService>(() => FootballApiService());
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<OddsService>(() => OddsService());

  // Initialize database when available on the current platform.
  try {
    await getIt<DatabaseService>().initDatabase();
  } catch (e) {
    debugPrint('Database initialization skipped: $e');
  }
}
