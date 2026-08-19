import 'dart:async';
import 'package:flutter/material.dart';
import 'main_menu_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MainMenuScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF0D5C3A);
    const goldAccent = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [Color(0xFF1B3B2B), Colors.black],
              radius: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: goldAccent, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: goldAccent.withOpacity(0.2),
                          blurRadius: 25,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset('assets/logo.png', height: 180),
                  ),
                ),
              ),
              const SizedBox(height: 35),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    'أهلاً وسهلاً بكم في التطبيق الرسمي لأمانة السر\nلثانوية الشيخ المربي عبد الكريم الرفاعي الشرعية للبنين',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: goldAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(goldAccent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}