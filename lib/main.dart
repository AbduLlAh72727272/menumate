import 'package:flutter/material.dart';
import 'core/theme/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/search_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/checkout_screen.dart';

void main() {
  runApp(const MenuMateApp());
}

class MenuMateApp extends StatelessWidget {
  const MenuMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MenuMate - Next Level Food App',
      debugShowCheckedModeBanner: false,
      theme: MenuMateTheme.lightTheme,
      darkTheme: MenuMateTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
      routes: {
        '/home': (context) => const MenuMateHomeScreen(),
        '/search': (context) => const SearchScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/checkout': (context) => const CheckoutScreen(),
      },
    );
  }
}
