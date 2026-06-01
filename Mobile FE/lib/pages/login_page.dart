import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../kerangka/login_kerangka.dart';
import '../services/auth_service.dart'; // Import service
import 'home_page.dart';
import 'forgot_password_page.dart'; // Sesuaikan path-nya jika beda folder

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _rememberMe = false;

  // Definisikan controller dan service
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiAuthService _authService = ApiAuthService();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email dan password wajib diisi!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // 🎉 LOGIKA BARU: Tanpa OTP, langsung masuk ke Home Page!

      // (Opsional: Di sini nanti kamu bisa simpan result['token'] ke SharedPreferences)
      ApiAuthService.token = result['token'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Login berhasil!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const UniventHomePage(isLoggedIn: true),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Login gagal.")),
      );
    }
  }

  // Dialog popup instan untuk memasukkan 6 digit OTP
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
              "Kode OTP telah dikirim ke email $email. Silakan periksa kotak masuk Anda.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: "Masukkan 6 Digit OTP",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              final res = await _authService.verifyOtp(
                email,
                otpController.text.trim(),
              );
              if (res['success'] == true) {
                // Simpan token bearer di storage jika diperlukan (misal shared_preferences)
                // String token = res['token'];

                Navigator.pop(context); // Tutup Dialog
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
                  SnackBar(content: Text(res['message'] ?? "OTP Salah.")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
            ),
            child: const Text(
              "Verifikasi",
              style: TextStyle(color: Colors.white),
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
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40,
                ),
                child: Column(
                  children: [
                    LoginKerangka.headerSection(context),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LoginKerangka.inputField(
                            label: "Email Address",
                            hint: "name@example.com",
                            icon: Icons.mail_outline,
                            controller:
                                _emailController, // <- MASUKKAN CONTROLLER
                          ),
                          const SizedBox(height: 20),
                          LoginKerangka.inputField(
                            label: "Password",
                            hint: "........",
                            icon: Icons.lock_outline,
                            isPassword: true,
                            controller:
                                _passwordController, // <- MASUKKAN CONTROLLER
                            rightLabel: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot password?",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // ... (Checkbox rememberMe tetap sama)
                          const SizedBox(height: 32),

                          _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.primaryPink,
                                  ),
                                )
                              : LoginKerangka.primaryButton(
                                  "Log In Sekarang",
                                  _handleLogin,
                                ), // <- BIND KE METHOD

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
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
