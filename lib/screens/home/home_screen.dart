import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../favorites/favorites_screen.dart';
import '../match/match_list_screen.dart';
import '../team/team_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MatchListScreen(),
    const TeamListScreen(),
    const FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.sports_soccer),
            label: context.l10n.matches,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shield),
            label: context.l10n.teams,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: context.l10n.favorites,
          ),
        ],
      ),
    );
  }
}
