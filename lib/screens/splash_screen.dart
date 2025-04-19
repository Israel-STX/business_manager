import 'package:flutter/material.dart';
import 'dart:async';
import 'home_shell.dart';

// splash screen when the app first loads
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // wait 3 seconds, then go to the main home shell
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // set background color to white
      backgroundColor: Colors.white,

      // center the logo in the screen
      body: Center(
        child: Image.asset(
          'logo/biz.png',
        
        // set logo width
          width: 150,
        ),
      ),
    );
  }
}
