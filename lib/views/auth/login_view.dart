import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/user_model_firebase.dart';
import 'package:project_flutter/views/core/main_navigation_shell.dart';
import 'package:project_flutter/views/auth/register_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _loginFormKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool _isLoading = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String name) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 28.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Styled Circular Icon Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F2625)
                        : const Color(0xFFE6F4F1), // Soft teal background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF0D9488),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  "Masuk Berhasil",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A2E44),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                // Content Text
                Text(
                  "Selamat datang kembali, $name! Mari terus bersama menjaga kualitas udara bersih dan lingkungan sehat.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                // Premium Styled Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainNavigationShell(),
                        ),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      "Mulai Sekarang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.0),
          ),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 28.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Styled Circular Icon Badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3B1E1E)
                        : const Color(0xFFFEE2E2), // Soft red background
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_rounded,
                    color: Color(0xFFEF4444),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
                Text(
                  "Gagal Masuk",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A2E44),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 12),
                // Content Text
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                // Premium Styled Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      "Coba Lagi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _login() async {
    final email = emailController.text.trim();
    final pass = passwordController.text;

    setState(() {
      _isLoading = true;
    });

    final user = await FirebaseAuthService.instance.loginUser(email, pass);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (user != null) {
      // Save session
      final prefs = await SharedPreferences.getInstance();
      if (user.id != null) {
        await prefs.setString('current_user_firestore_id', user.id!);
      }
      await prefs.setString('current_user_name', user.nama);
      await prefs.setString('current_user_email', user.email);
      await prefs.setString('current_user_role', user.role);

      if (mounted) {
        _showSuccessDialog(user.nama);
      }
    } else {
      if (mounted) {
        _showErrorDialog(
          'Email atau Kata Sandi yang Anda masukkan salah. Silakan coba lagi.',
        );
      }
    }
  }

  void _loginWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    final user = await FirebaseAuthService.instance.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (user != null) {
      // Save session
      final prefs = await SharedPreferences.getInstance();
      if (user.id != null) {
        await prefs.setString('current_user_firestore_id', user.id!);
      }
      await prefs.setString('current_user_name', user.nama);
      await prefs.setString('current_user_email', user.email);
      await prefs.setString('current_user_role', user.role);

      if (mounted) {
        _showSuccessDialog(user.nama);
      }
    } else {
      if (mounted) {
        _showErrorDialog(
          'Gagal masuk menggunakan akun Google. Silakan coba lagi.',
        );
      }
    }
  }

  void _fillDemoAccount() {
    emailController.text = "andi.pratama@gmail.com";
    passwordController.text = "password123";
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akun demo berhasil diisi!'),
        backgroundColor: Colors.indigo,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _fillDemoAdminAccount() {
    emailController.text = "admin.ruas@gmail.com";
    passwordController.text = "admin123";
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Akun demo Admin berhasil diisi!'),
        backgroundColor: Colors.teal,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF4F8FB);
    final Color cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final Color textColor = isDark
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF1A2E44);
    final Color subTextColor = isDark ? const Color(0xFF94A3B8) : Colors.grey;
    final Color dividerColor = isDark
        ? const Color(0xFF334155)
        : Colors.grey[300]!;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _loginFormKey,
              child: Column(
                children: [
                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          width: 85,
                          height: 85,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/images/logo_ruas.png'),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Selamat Datang",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const Text(
                          "Kembali Melangkah !",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Masuk untuk melanjutkan kontribusimu di lingkungan bersih RUAS",
                          style: TextStyle(fontSize: 14, color: subTextColor),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: isDark
                          ? Border.all(color: const Color(0xFF334155))
                          : null,
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: isDark ? Colors.black26 : Colors.black12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: textColor),
                          decoration: _buildInputDecoration(
                            "Masukkan Email Anda",
                            Icons.email_outlined,
                            isDark,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Email tidak boleh kosong";
                            }
                            if (!value.contains("@")) {
                              return "Format email tidak valid";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Kata Sandi",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          obscuringCharacter: "*",
                          style: TextStyle(color: textColor),
                          decoration:
                              _buildInputDecoration(
                                "Masukkan Kata Sandi Anda",
                                Icons.lock_outline_rounded,
                                isDark,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kata Sandi tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     onPressed: () {
                        //       ScaffoldMessenger.of(context).showSnackBar(
                        //         const SnackBar(
                        //           content: Text(
                        //             'Fitur lupa kata sandi belum tersedia.',
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     child: const Text(
                        //       "Lupa Kata Sandi?",
                        //       style: TextStyle(
                        //         color: Colors.teal,
                        //         fontWeight: FontWeight.bold,
                        //         fontSize: 12,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF0F4C43)
                                  : const Color(0xFF1A2E44),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (_loginFormKey.currentState!
                                        .validate()) {
                                      _login();
                                    }
                                  },
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "Masuk Sekarang",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(height: 12),
                          // Demo filler button
                          Row(
                            children: [
                              // Expanded(
                              //   child: SizedBox(
                              //     height: 50,
                              //     child: OutlinedButton.icon(
                              //       onPressed: _fillDemoAccount,
                              //       icon: const Icon(Icons.person_outline, size: 16),
                              //       label: const Text('Demo User'),
                              //       style: OutlinedButton.styleFrom(
                              //         foregroundColor: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                              //         side: BorderSide(color: isDark ? const Color(0xFF4338CA) : Colors.indigo),
                              //         shape: RoundedRectangleBorder(
                              //           borderRadius: BorderRadius.circular(12),
                              //         ),
                              //         padding: EdgeInsets.zero,
                              //       ),
                              //     ),
                              //   ),
                              // ),
                              //
                            ],
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(color: dividerColor, thickness: 1),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                "atau",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: dividerColor, thickness: 1),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSocialButton(
                          label: "Masuk dengan Google",
                          icon: Icons.g_mobiledata_rounded,
                          iconColor: Colors.red,
                          isDark: isDark,
                          onPressed: _loginWithGoogle,
                        ),
                        // const SizedBox(height: 12),
                        // _buildSocialButton(
                        //   label: "Masuk dengan Apple",
                        //   icon: Icons.apple,
                        //   iconColor: isDark ? Colors.white : Colors.black,
                        //   isDark: isDark,
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text.rich(
                    TextSpan(
                      text: "Belum Punya Akun?",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterView(),
                                ),
                              );
                            },
                          text: " Daftar Sekarang",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hint,
    IconData prefixIcon,
    bool isDark,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark ? const Color(0xFF64748B) : Colors.grey,
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAF9),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(width: 1.5, color: Colors.teal),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF1A2E44),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : Colors.grey[300]!,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed ?? () {},
      icon: Icon(icon, color: iconColor, size: 24),
      label: Text(
        label,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
