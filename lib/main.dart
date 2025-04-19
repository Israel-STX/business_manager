import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'theme.dart';

void main() async {
  // this line makes sure flutter is ready
  WidgetsFlutterBinding.ensureInitialized();

  // start firebase so we can use firestore
  await Firebase.initializeApp();

  // run the actual app
  runApp(const BusinessManagerApp());
}

// this is the main app widget
class BusinessManagerApp extends StatelessWidget {
  const BusinessManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Manager',
      theme: AppThemes.bizTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
