import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart'; // Update the path as necessary

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3)); // Display splash for 3 seconds
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: HomeScreen(), // You can use the HomeScreen here
          );
        },
        transitionDuration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.deepOrange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Animation
                Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: Colors.white,
                ).animate().fadeIn(duration: 1200.ms).scale(duration: 1200.ms, curve: Curves.elasticOut),
                SizedBox(height: 20),
                // App Name Animation
                Text(
                  "World Cuisine Explorer",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ).animate().fadeIn(duration: 800.ms, delay: 1200.ms),
                SizedBox(height: 10),
                // Tagline Animation
                Text(
                  "Discover Recipes From Around the World",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ).animate().slideY(duration: 800.ms, delay: 1600.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
