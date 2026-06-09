import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart'; // Sesuaikan lokasi import-mu

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _otpCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _isLoading = false;
  bool _isOtpSent = false; // Flag penentu UI mana yang tampil

  // --- Fungsi 1: Kirim Email ---
  void _sendOtp() async {
    if (_emailCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);

    final result = await ApiAuthService.forgotPassword(
      _emailCtrl.text,
    ); // Sesuaikan nama class Service-mu

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      if (result['success'] == true) {
        setState(() => _isOtpSent = true); // Ubah tampilan ke form OTP
      }
    }
  }

  // --- Fungsi 2: Reset Password ---
  void _resetPassword() async {
    if (_otpCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) return;

    if (_passwordCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Password tidak cocok!")));
      return;
    }

    setState(() => _isLoading = true);

    final result = await ApiAuthService.resetPassword(
      _emailCtrl.text,
      _otpCtrl.text,
      _passwordCtrl.text,
      _confirmCtrl.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      if (result['success'] == true) {
        Navigator.pop(context); // Kembali ke halaman Login jika sukses
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkBlue),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOtpSent ? "Reset Password" : "Lupa Password?",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _isOtpSent
                      ? "Masukkan kode OTP yang dikirim ke email beserta password barumu."
                      : "Masukkan email yang terdaftar, kami akan mengirimkan OTP untuk reset password.",
                  style: const TextStyle(color: Colors.blueGrey, fontSize: 14),
                ),
                const SizedBox(height: 32),

                // --- FORM 1: MINTA OTP ---
                if (!_isOtpSent) ...[
                  TextField(
                    controller: _emailCtrl,
                    decoration: InputDecoration(
                      labelText: "Email Address",
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _sendOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "KIRIM OTP",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                // --- FORM 2: ISI OTP & NEW PASSWORD ---
                if (_isOtpSent) ...[
                  TextField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Kode OTP (6 Angka)",
                      prefixIcon: const Icon(Icons.security),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password Baru",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Konfirmasi Password Baru",
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.darkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        "SIMPAN PASSWORD BARU",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // 👇 TAMBAHKAN KODE TOMBOL RESEND OTP DI SINI 👇
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: _isLoading
                          ? null
                          : _sendOtp, // Memanggil ulang fungsi pengirim email
                      child: const Text(
                        "Belum menerima kode? Kirim Ulang",
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              ),
            ),
        ],
      ),
    );
  }
}
