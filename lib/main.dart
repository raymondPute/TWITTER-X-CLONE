import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Make sure to import this
import 'welcome_screen.dart';
import 'home_page.dart';
import 'login_screen.dart';
import 'register_page.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();  // Make sure Flutter is initialized
  await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform, // Use the Firebase options
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twitter Clone',
      theme: ThemeData(
        primaryColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ).copyWith(secondary: Colors.blue),
      ),
      home: WelcomeScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
