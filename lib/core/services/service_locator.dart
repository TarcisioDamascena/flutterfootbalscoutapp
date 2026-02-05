import 'package:get_it/get_it.dart';

import '../../services/database_service.dart';
import '../../services/football_api_service.dart';
import '../../services/odds_service.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerLazySingleton<FootballApiService>(() => FootballApiService());
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<OddsService>(() => OddsService());

  // Initialize database
  await getIt<DatabaseService>().initDatabase();
}
