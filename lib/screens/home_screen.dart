import 'package:flutter/material.dart';

import '../widgets/mini_player.dart';
import 'home_tab.dart';
import 'search_tab.dart';

/// App shell: Home and Search tabs, with the mini player above the bottom bar.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choira Music')),
      // IndexedStack keeps each tab's scroll position when switching tabs
      body: IndexedStack(
        index: _tab,
        children: const [HomeTab(), SearchTab()],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _tab,
            onDestinationSelected: (i) => setState(() => _tab = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
