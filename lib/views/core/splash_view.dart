import 'dart:async';

import 'package:flutter/material.dart';
import 'package:project_flutter/views/auth/login_view.dart';
import 'package:project_flutter/views/core/main_navigation_shell.dart';
import 'package:project_flutter/views/core/onboarding_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startLoadingAnimation();
  }

  void _startLoadingAnimation() {
    const totalDuration = Duration(milliseconds: 2500);
    const interval = Duration(milliseconds: 50);
    final totalSteps = totalDuration.inMilliseconds / interval.inMilliseconds;
    int currentStep = 0;

    _timer = Timer.periodic(interval, (timer) {
      currentStep++;
      setState(() {
        _progress = currentStep / totalSteps;
      });

      if (currentStep >= totalSteps) {
        timer.cancel();
        _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('current_user_id');
    final userFirestoreId = prefs.getString('current_user_firestore_id');
    final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;

    if (!mounted) return;

    if (userId != null || userFirestoreId != null) {
      // User is logged in, navigate straight to Main Navigation Shell
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationShell()),
        (route) => false,
      );
    } else {
      // User is not logged in
      if (seenOnboarding) {
        // Already completed onboarding, go to Login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginView()),
        );
      } else {
        // Show onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingView()),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int percentValue = (_progress * 100).clamp(0, 100).toInt();

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/project_akhir/baground_1.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback elegant gradient background if image is missing
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFE6F4F1), Color(0xFF0D9488)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                );
              },
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32.0,
                vertical: 24.0,
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Logo Container with RUAS Logo and title
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Image.asset(
                          'assets/images/logo_ruas.png',
                          height: 200,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 120,
                              width: 120,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.air_rounded,
                                size: 60,
                                color: Color(0xFF0D9488),
                              ),
                            );
                          },
                        ),
                        // const SizedBox(height: 16),
                        // RUAS
                        // const Text(
                        //   'RUAS',
                        //   style: TextStyle(
                        //     fontSize: 36,
                        //     fontWeight: FontWeight.w900,
                        //     color: Color(0xFF0F4C43),
                        //     letterSpacing: 2.0,
                        //   ),
                        // ),
                        // const SizedBox(height: 6),
                        // // Subtitle
                        // const Text(
                        //   'Ruang Napas Untuk Semua',
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w600,
                        //     color: Color(0xFF1A2E44),
                        //     letterSpacing: 0.5,
                        //   ),
                        // ),
                        const SizedBox(height: 24),
                        // Categories List
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Pantau  •  Laporkan  •  Edukasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D9488),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 4),
                  // Loading Section at the bottom
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Memuat...',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Rounded Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          height: 6,
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Percentage
                      Text(
                        '$percentValue%',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
