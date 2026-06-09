import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/login_kerangka.dart';
import '../services/auth_service.dart'; // Import service
import 'home_page.dart';
import 'forgot_password_page.dart'; // Sesuaikan path-nya jika beda folder
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Definisikan controller dan service
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiAuthService _authService = ApiAuthService();
  bool _isLoading = false;
  bool _isLoadingGoogle = false;

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
      // 👇 BUKA BRANKAS DAN SIMPAN STATUS
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      print(
        "🚨 INVESTIGASI LOGIN: Token dari Laravel adalah -> ${result['token']}",
      );

      if (result['token'] != null) {
        await prefs.setString('token', result['token']);
      } else {
        print("❌ GAWAT! Tokennya NULL, pantesan brankasnya kosong!");
      }

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

  //google
  void _handleGoogleLogin() async {
    setState(() => _isLoadingGoogle = true);

    final result = await ApiAuthService.loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoadingGoogle = false);

    if (result['success'] == true) {
      // 👇 BUKA BRANKAS DAN SIMPAN STATUS UNTUK GOOGLE LOGIN
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);

      // (Opsional) Jika API login Google juga mengembalikan token
      if (result['token'] != null) {
        await prefs.setString('token', result['token']);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Login Google berhasil!")),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const UniventHomePage(isLoggedIn: true),
        ),
        (route) => false,
      );
    } else {
      if (result['message'] != 'Dibatalkan oleh user') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: ${result['message']}")));
      }
    }
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
                          _isLoadingGoogle
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.redAccent,
                                  ),
                                )
                              : ElevatedButton.icon(
                                  onPressed:
                                      _handleGoogleLogin, // Langsung panggil fungsi di sini
                                  icon: const Icon(
                                    Icons.g_mobiledata,
                                    color: Colors.red,
                                    size: 32,
                                  ),
                                  label: const Text(
                                    "Google Account",
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 1,
                                    minimumSize: const Size(
                                      double.infinity,
                                      50,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
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
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const UniventHomePage(isLoggedIn: false),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
