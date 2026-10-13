import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/home_feed.dart';
import 'providers/player_provider.dart';
import 'providers/search_feed.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Home loads its first page as soon as the app starts
        ChangeNotifierProvider(create: (_) => HomeFeed()),
        // Search starts empty and loads when the user types
        ChangeNotifierProvider(create: (_) => SearchFeed()),
        ChangeNotifierProvider(create: (_) => PlayerProvider()),
      ],
      child: MaterialApp(
        title: 'Choira Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B0B0F),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFC83D),
            onPrimary: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0B0B0F),
            centerTitle: true,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
