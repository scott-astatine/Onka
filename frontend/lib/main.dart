import 'presentation/screens/home_screen.dart';
import 'presentation/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: OnkaApp()));
}

class OnkaApp extends StatelessWidget {
  const OnkaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OnKa',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
