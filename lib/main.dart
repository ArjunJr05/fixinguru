import 'package:fixinguru/front/first.dart';
import 'package:fixinguru/home/homepage.dart';
import 'package:fixinguru/home/mainpage.dart';
import 'package:fixinguru/login/loginpage.dart';
import 'package:fixinguru/login/task.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
        ),
      ),
      home: OnboardingScreen(),
    );
  }
}
