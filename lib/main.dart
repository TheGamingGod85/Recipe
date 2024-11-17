import 'package:flutter/material.dart';
import 'package:recipes/screens/splash_screen.dart';

void main() {
  runApp(WorldCuisineExplorerApp());
}

class WorldCuisineExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Cuisine Explorer',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: SplashScreen(),
    );
  }
}
