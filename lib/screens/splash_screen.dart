import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'user/user_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Artificial delay for splash effect
    await Future.delayed(const Duration(seconds: 2));

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');

      // Debugging: Print to console
      debugPrint("SPLASH SCREEN: Checking token...");
      debugPrint("SPLASH SCREEN: Token found: $token");

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        debugPrint("SPLASH SCREEN: Navigating to Dashboard");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserDashboard()),
        );
      } else {
        debugPrint("SPLASH SCREEN: Navigating to Login");
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      debugPrint("SPLASH SCREEN: Error reading token: $e");
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             // You can add your logo here
             Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFFECB3), width: 2),
                ),
                child: const Icon(Icons.sports_tennis, size: 48, color: Color(0xFFFFC107)),
             ),
             const SizedBox(height: 24),
             const CircularProgressIndicator(
               color: Color(0xFFFFC107),
             ),
          ],
        ),
      ),
    );
  }
}
