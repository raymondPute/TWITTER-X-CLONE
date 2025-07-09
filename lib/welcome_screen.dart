import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background set to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/Xlogo.png',
              height: 100,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Twitter Clone',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ), // Bold and white for better contrast
            ),
            SizedBox(height: 40),

            // Login button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(200, 60), // Larger button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Log In',
                style: TextStyle(
                  fontSize: 20, // Larger font size
                  fontWeight: FontWeight.bold, // Bold text
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Register button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                minimumSize: Size(200, 60), // Larger button size
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                'Register',
                style: TextStyle(
                  fontSize: 20, // Larger font size
                  fontWeight: FontWeight.bold, // Bold text
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
