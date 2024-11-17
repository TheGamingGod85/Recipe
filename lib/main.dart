import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(WorldCuisineExplorerApp());
}

class WorldCuisineExplorerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'World Cuisine Explorer',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}
