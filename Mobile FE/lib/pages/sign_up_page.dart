import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/sign_up_kerangka.dart';
import '../kerangka/login_kerangka.dart';
import '../services/auth_service.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final ApiAuthService _authService = ApiAuthService();
  bool _isLoading = false;

  void _handleRegister() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Semua field wajib diisi!")));
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Konfirmasi password tidak cocok!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      // Setelah sukses daftar, lempar ke halaman login untuk verifikasi OTP pertama kali
      _showOtpDialog(_emailController.text.trim());
    } else {
      // Jika error validasi dari laravel
      String errorMsg = result['message'] ?? "Registrasi gagal.";
      if (result['errors'] != null) {
        errorMsg = result['errors'].toString();
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  // 👇 TAMBAHKAN FUNGSI INI 👇
  void _showOtpDialog(String email) {
    final TextEditingController otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text(
          "Verifikasi OTP",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Kode OTP pendaftaran telah dikirim ke email $email. Silakan periksa kotak masuk/spam Anda.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: "Masukkan 6 Digit OTP",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            // 👇 TAMBAHKAN TOMBOL KIRIM ULANG DI SINI 👇
            TextButton(
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Meminta kode OTP baru...")),
                );
                final res = await _authService.resendOtp(email);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(res['message'] ?? "Cek email Anda.")),
                );
              },
              child: const Text(
                "Kirim Ulang Kode",
                style: TextStyle(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Tutup popup kalau batal
            child: const Text(
              "Batal",
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Panggil API verifikasi OTP
              final res = await _authService.verifyOtp(
                email,
                otpController.text.trim(),
              );
              if (!mounted) return;
              if (res['success'] == true) {
                Navigator.pop(context); // Tutup popup OTP

                // Langsung masuk ke HomePage setelah sukses verifikasi!
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const UniventHomePage(isLoggedIn: true),
                  ),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res['message'] ?? "OTP Salah atau Kadaluarsa.",
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
            ),
            child: const Text(
              "Verifikasi",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              children: [
                SignUpKerangka.headerSection(() => Navigator.pop(context)),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SignUpKerangka.inputField(
                        label: "Email Address",
                        hint: "name@example.com",
                        icon: Icons.mail_outline,
                        controller: _emailController, // <- PASANG
                      ),
                      const SizedBox(height: 20),
                      SignUpKerangka.inputField(
                        label: "Password",
                        hint: "........",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        controller: _passwordController, // <- PASANG
                      ),
                      const SizedBox(height: 20),
                      SignUpKerangka.inputField(
                        label: "Confirm Password",
                        hint: "........",
                        icon: Icons.verified_user_outlined,
                        isPassword: true,
                        suffixIcon: Icons.visibility_outlined,
                        controller: _confirmPasswordController, // <- PASANG
                      ),
                      const SizedBox(height: 32),

                      _isLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.primaryPink,
                            )
                          : LoginKerangka.primaryButton(
                              "Daftar Akun Baru",
                              _handleRegister,
                            ), // <- BIND

                      const SizedBox(height: 24),
                      LoginKerangka.dividerOr(),
                      const SizedBox(height: 24),
                      LoginKerangka.googleButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
