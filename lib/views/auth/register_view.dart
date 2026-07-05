import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:project_flutter/database/firebase_auth_service.dart';
import 'package:project_flutter/models/user_model.dart';
import 'package:project_flutter/views/auth/login_view.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _registerFormKey = GlobalKey<FormState>();
  bool obscureNewPassword = true;
  bool isCheck = false;
  bool _isLoading = false;

  // Controllers
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController tempatLahirController = TextEditingController();
  final TextEditingController tanggalLahirController = TextEditingController();

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    tempatLahirController.dispose();
    tanggalLahirController.dispose();
    super.dispose();
  }

  Future<void> _selectTanggalLahir() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF0D9488),
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E293B) : Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF1A2E44),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        tanggalLahirController.text = DateFormat(
          'dd MMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  void _showTermsBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Syarat & Ketentuan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A2E44),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: isDark ? const Color(0xFF334155) : null),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Selamat datang di RUAS (Rukun Udara & Asri Selaras). Dengan mendaftar dan menggunakan aplikasi ini, Anda setuju untuk mematuhi ketentuan berikut:",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "1. Akun Pengguna",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Anda wajib memberikan informasi pendaftaran yang akurat, lengkap, dan terbaru termasuk nama lengkap, tempat lahir, dan tanggal lahir. Anda bertanggung jawab penuh atas keamanan kata sandi Anda.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "2. Penggunaan Layanan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Layanan ini ditujukan untuk memantau kualitas udara, melaporkan isu lingkungan, serta mempelajari edukasi lingkungan. Anda dilarang mengunggah laporan palsu atau konten yang mengandung SARA.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "3. Hak Cipta & Konten",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Semua konten edukasi, desain, dan ilustrasi di dalam aplikasi adalah hak milik RUAS. Penggunaan konten di luar aplikasi wajib mencantumkan sumber.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Saya Mengerti",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPrivacyBottomSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Kebijakan Privasi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1A2E44),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              Divider(color: isDark ? const Color(0xFF334155) : null),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kebijakan Privasi ini menjelaskan bagaimana kami mengumpulkan, menggunakan, dan melindungi data pribadi Anda saat menggunakan aplikasi RUAS:",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "1. Informasi yang Kami Kumpulkan",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kami mengumpulkan data pendaftaran seperti nama, email, nomor telepon, serta tempat & tanggal lahir. Kami juga mengumpulkan koordinat lokasi GPS saat Anda membuat laporan lingkungan.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "2. Penggunaan Data",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Data Anda digunakan untuk memverifikasi identitas, menindaklanjuti laporan lingkungan ke instansi terkait, serta memberikan notifikasi perkembangan kualitas udara di sekitar Anda.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "3. Keamanan Informasi",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kami berkomitmen melindungi data pribadi Anda dari akses tidak sah melalui langkah-langkah enkripsi database dan kontrol akses ketat.",
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF475569),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D9488),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Saya Mengerti",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog() {
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
                  "Pendaftaran Berhasil",
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
                  "Akun Anda berhasil didaftarkan! Silakan masuk menggunakan email dan kata sandi Anda untuk bergabung bersama RUAS.",
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginView(),
                        ),
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
                      "Masuk Sekarang",
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
                  "Pendaftaran Gagal",
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
                      "Tutup",
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

  void _register() async {
    if (_registerFormKey.currentState == null ||
        !_registerFormKey.currentState!.validate()) {
      return;
    }
    if (!isCheck) {
      _showErrorDialog(
        "Anda harus menyetujui Syarat & Ketentuan serta Kebijakan Privasi terlebih dahulu.",
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final now = DateTime.now();
    final formattedDate = DateFormat('d MMM yyyy', 'id_ID').format(now);

    final user = UserModel(
      nama: namaController.text.trim(),
      email: emailController.text.trim(),
      nomorTelp: phoneController.text.trim(),
      password: passwordController.text,
      tanggalDaftar: formattedDate,
      tempatLahir: tempatLahirController.text.trim(),
      tanggalLahir: tanggalLahirController.text.trim(),
      role: 'user',
    );

    final result = await FirebaseAuthService.instance.registerUserModel(user);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (result != null) {
      _showSuccessDialog();
    } else {
      _showErrorDialog(
        "Email yang Anda masukkan sudah terdaftar! Gunakan email lain.",
      );
    }
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

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _registerFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
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
                          "Buat Akun",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const Text(
                          "Mulai Langkahmu !",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Daftarkan dirimu untuk bergabung ke lingkungan bersih RUAS",
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
                          "Nama Lengkap",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: namaController,
                          style: TextStyle(color: textColor),
                          decoration: _buildInputDecoration(
                            "Masukkan Nama Lengkap Anda",
                            Icons.person_outline,
                            isDark,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nama Lengkap tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
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
                            "Masukkan Email Aktif",
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
                          "Nomor Telepon",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: textColor),
                          decoration: _buildInputDecoration(
                            "Masukkan Nomor Telepon",
                            Icons.call,
                            isDark,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Nomor Telepon tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Tempat Lahir",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: tempatLahirController,
                          style: TextStyle(color: textColor),
                          decoration: _buildInputDecoration(
                            "Masukkan Tempat Lahir Anda",
                            Icons.location_city_outlined,
                            isDark,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Tempat Lahir tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Tanggal Lahir",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: tanggalLahirController,
                          readOnly: true,
                          onTap: _selectTanggalLahir,
                          style: TextStyle(color: textColor),
                          decoration: _buildInputDecoration(
                            "Pilih Tanggal Lahir",
                            Icons.calendar_today_outlined,
                            isDark,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Tanggal Lahir tidak boleh kosong";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Kata Sandi Baru",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscureNewPassword,
                          obscuringCharacter: "*",
                          style: TextStyle(color: textColor),
                          decoration:
                              _buildInputDecoration(
                                "Buat Kata Sandi Kuat",
                                Icons.lock_outline_rounded,
                                isDark,
                              ).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    obscureNewPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => setState(
                                    () => obscureNewPassword =
                                        !obscureNewPassword,
                                  ),
                                ),
                              ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Kata Sandi tidak boleh kosong";
                            }
                            if (value.length < 6) {
                              return "Kata Sandi minimal harus 6 karakter";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        Theme(
                          data: ThemeData(
                            unselectedWidgetColor: isDark
                                ? const Color(0xFF64748B)
                                : Colors.grey,
                            checkboxTheme: CheckboxThemeData(
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF64748B)
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          child: CheckboxListTile(
                            title: Text.rich(
                              TextSpan(
                                text: "Saya setuju dengan",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                children: [
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showTermsBottomSheet,
                                    text: " Syarat & Ketentuan",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: " dan",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  TextSpan(
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = _showPrivacyBottomSheet,
                                    text: " Kebijakan Privasi",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            value: isCheck,
                            activeColor: const Color(0xFF0F4C43),
                            checkColor: Colors.white,
                            contentPadding: EdgeInsets.zero,
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (bool? val) {
                              setState(() {
                                isCheck = val ?? false;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
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
                            onPressed: _isLoading ? null : _register,
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
                                    "Daftar Sekarang",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 35),
                  Text.rich(
                    TextSpan(
                      text: "Sudah Punya Akun?",
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                      children: [
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginView(),
                                ),
                              );
                            },
                          text: " Masuk Sekarang",
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
}
