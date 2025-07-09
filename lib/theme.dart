import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter Clone',
      theme: ThemeData(
        primaryColor: Colors.black, // Primary color to match Twitter X theme
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark, // Use dark mode for better contrast
        ).copyWith(secondary: Colors.blue), // Accent color for buttons, highlights
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Update bodyText1 to bodyLarge
          bodyMedium: TextStyle(color: Colors.white), // Update bodyText2 to bodyMedium
        ),
      ),
      home: WelcomeScreen(), // Change to HomePage() when you're ready to go live
    );
  }
}
