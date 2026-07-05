import 'package:flutter/material.dart';
import 'package:project_flutter/views/auth/login_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Pantau\nKualitas Udara',
      'subtitle':
          'Pantau kualitas udara di sekitar Anda secara mudah dan real-time.',
      'image': 'assets/images/project_akhir/splash_1.png',
      'highlights': [
        {'icon': Icons.thermostat, 'text': 'Sensor Kualitas Udara Real-Time'},
        {
          'icon': Icons.health_and_safety,
          'text': 'Rekomendasi Aktivitas Sehat',
        },
        {'icon': Icons.map, 'text': 'Peta Polusi Interaktif Wilayah'},
      ],
    },
    {
      'title': 'Laporkan\nPermasalahan Lingkungan',
      'subtitle': 'Laporkan masalah lingkungan langsung dari lokasi kejadian.',
      'image': 'assets/images/project_akhir/splash_2.png',
      'highlights': [
        {
          'icon': Icons.camera_alt,
          'text': 'Unggah Foto Bukti & Detail Laporan',
        },
        {'icon': Icons.my_location, 'text': 'Pinpoint Lokasi GPS Akurat'},
        {'icon': Icons.track_changes, 'text': 'Pantau Progres Tindak Lanjut'},
      ],
    },
    {
      'title': 'Edukasi\nUntuk Masa Depan',
      'subtitle':
          'Pelajari cara menjaga udara bersih untuk masa depan yang lebih baik.',
      'image': 'assets/images/project_akhir/splash_3.png',
      'highlights': [
        {'icon': Icons.menu_book, 'text': 'Artikel & Tips Edukasi Lingkungan'},
        {'icon': Icons.eco, 'text': 'Aksi Nyata & Kegiatan Ramah Lingkungan'},
        {'icon': Icons.workspace_premium, 'text': 'Kumpulkan Lencana Menarik'},
      ],
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  Widget _buildHighlightItem(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Color(0xFFE6F4F1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF0D9488)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full-screen PageView
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              final data = _onboardingData[index];
              final highlights =
                  data['highlights'] as List<Map<String, dynamic>>;

              if (index < 3) {
                // Page 1 & 2: Background image layout (stretch to cover)
                return Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: Image.asset(
                        data['image']!,
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                    // Gradient overlay to fade the top edge of the image into the background
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 280,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white,
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    // Foreground content
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 32),
                            Text(
                              data['title']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A2E44),
                                height: 1.3,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                              ),
                              child: Text(
                                data['subtitle']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF64748B),
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Highlights Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  _buildHighlightItem(
                                    highlights[0]['icon'] as IconData,
                                    highlights[0]['text'] as String,
                                  ),
                                  const Divider(
                                    height: 20,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                  _buildHighlightItem(
                                    highlights[1]['icon'] as IconData,
                                    highlights[1]['text'] as String,
                                  ),
                                  const Divider(
                                    height: 20,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                  _buildHighlightItem(
                                    highlights[2]['icon'] as IconData,
                                    highlights[2]['text'] as String,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 120),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                // Page 3: Centered illustration layout
                // return SafeArea(
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 24.0),
                //     child: Column(
                //       crossAxisAlignment: CrossAxisAlignment.stretch,
                //       children: [
                //         const SizedBox(height: 32),
                //         Text(
                //           data['title']!,
                //           textAlign: TextAlign.center,
                //           style: const TextStyle(
                //             fontSize: 26,
                //             fontWeight: FontWeight.w800,
                //             color: Color(0xFF1A2E44),
                //             height: 1.3,
                //             letterSpacing: -0.5,
                //           ),
                //         ),
                //         const SizedBox(height: 16),
                //         Padding(
                //           padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //           child: Text(
                //             data['subtitle']!,
                //             textAlign: TextAlign.center,
                //             style: const TextStyle(
                //               fontSize: 14,
                //               color: Color(0xFF64748B),
                //               height: 1.5,
                //             ),
                //           ),
                //         ),
                //         const Spacer(),
                //         // Centered Container for splash_3
                //         Expanded(
                //           flex: 4,
                //           child: Center(
                //             child: Image.asset(
                //               height: 500,
                //               width: 500,
                //               data['image']!,
                //               fit: BoxFit.fitHeight,
                //             ),
                //           ),
                //         ),
                //         const Spacer(),
                //         // Highlights Card
                //         Container(
                //           padding: const EdgeInsets.symmetric(
                //             horizontal: 16,
                //             vertical: 14,
                //           ),
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(20),
                //             border: Border.all(
                //               color: const Color(0xFFF1F5F9),
                //               width: 1.5,
                //             ),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.black.withOpacity(0.04),
                //                 blurRadius: 16,
                //                 offset: const Offset(0, 8),
                //               ),
                //             ],
                //           ),
                //           child: Column(
                //             children: [
                //               _buildHighlightItem(
                //                 highlights[0]['icon'] as IconData,
                //                 highlights[0]['text'] as String,
                //               ),
                //               const Divider(
                //                 height: 20,
                //                 color: Color(0xFFF1F5F9),
                //               ),
                //               _buildHighlightItem(
                //                 highlights[1]['icon'] as IconData,
                //                 highlights[1]['text'] as String,
                //               ),
                //               const Divider(
                //                 height: 20,
                //                 color: Color(0xFFF1F5F9),
                //               ),
                //               _buildHighlightItem(
                //                 highlights[2]['icon'] as IconData,
                //                 highlights[2]['text'] as String,
                //               ),
                //             ],
                //           ),
                //         ),
                //         const SizedBox(height: 120),
                //       ],
                //     ),
                //   ),
                // );
              }
              return null;
            },
          ),
          // Positioned Overlay for dots and navigation
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: _currentPage == _onboardingData.length - 1
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Centered indicator dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _onboardingData.length,
                            (index) => _buildDot(index),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Big Mulai Sekarang button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _completeOnboarding,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D9488),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Mulai Sekarang',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Left-aligned indicator dots
                        Row(
                          children: List.generate(
                            _onboardingData.length,
                            (index) => _buildDot(index),
                          ),
                        ),
                        // Skip text button (Lewati)
                        TextButton(
                          onPressed: _completeOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF0D9488),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Lewati',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}

