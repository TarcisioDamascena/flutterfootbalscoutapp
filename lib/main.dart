import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/services/service_locator.dart';
import 'core/themes/app_theme.dart';
import 'providers/match_provider.dart';
import 'providers/odds_provider.dart';
import 'providers/team_provider.dart';
import 'screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await setupServiceLocator();

  runApp(const FootballScoutApp());
}

class FootballScoutApp extends StatelessWidget {
  const FootballScoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TeamProvider()),
        ChangeNotifierProvider(create: (_) => MatchProvider()),
        ChangeNotifierProvider(create: (_) => OddsProvider()),
      ],
      child: MaterialApp(
        title: 'Football Scout',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
