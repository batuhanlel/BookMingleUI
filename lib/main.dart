import 'package:book_mingle_ui/constant.dart';
import 'package:book_mingle_ui/screens/onboarding/welcome_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      title: 'Book Mingle Demo UI',
      theme: ThemeData(
        primaryColor: kPrimaryColor,
        scaffoldBackgroundColor: Colors.white,
      ),
      // TODO check for existing user token, If exists navigate to the main otherwise navigate to the onboarding
      home: const WelcomeScreen(),
    );
  }
}
