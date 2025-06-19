import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_elderly_app/services/auth_service.dart';
import 'package:smart_elderly_app/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate a loading time
    if (mounted) {
      final authService = Provider.of<AuthService>(context, listen: false);
      if (authService.currentUser != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.gradientPurple, AppColors.gradientBlue],
              ),
            ),
          ),
          Center(
            child: Animate(
              effects: [
                FadeEffect(duration: 1200.ms),
                ScaleEffect(
                    duration: 1200.ms,
                    begin: const Offset(0.7, 0.7),
                    end: const Offset(1.1, 1.1),
                    curve: Curves.easeInOut),
              ],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientPurple.withOpacity(0.18),
                          blurRadius: 24,
                          spreadRadius: 2,
                          offset: Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.18),
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/images/splash_icon.png',
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Smart Elderly App',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
