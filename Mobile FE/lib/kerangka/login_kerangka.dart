import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../pages/sign_up_page.dart'; // <--- IMPORT HARUS DI SINI PALING ATAS!

class LoginKerangka {
  // 1. Header (Welcome Back & Sign Up)
  static Widget headerSection(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Welcome Back",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: AppTheme.darkText,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                // 👇 PINDAH KE HALAMAN REGISTER! 👇
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUpPage()),
                );
              },
              child: const Text(
                "Sign Up",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Input Field (Email & Password)
  static Widget inputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    Widget? rightLabel,
    TextEditingController? controller,
  }) {
    // Variabel awal untuk mendeteksi apakah password disembunyikan
    bool isHidden = isPassword;

    // Gunakan StatefulBuilder agar method static ini bisa mengubah state-nya sendiri
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkText,
                    fontSize: 14,
                  ),
                ),
                if (rightLabel != null) rightLabel,
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              obscureText: isHidden, // <--- BINDING KE VARIABEL STATE
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),

                // 👇 REVISI TOMBOL MATA DI SINI 👇
                suffixIcon: isPassword
                    ? IconButton(
                        icon: Icon(
                          isHidden
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                        onPressed: () {
                          // Ubah state isHidden ketika diklik
                          setState(() {
                            isHidden = !isHidden;
                          });
                        },
                      )
                    : null,

                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primaryPink),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 3. Tombol Login Utama Berbayang
  static Widget primaryButton(String text, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPink.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryPink,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 4. Tombol Google Account
  static Widget googleButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Text(
          "G",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
            fontSize: 18,
          ),
        ),
        label: const Text(
          "Google Account",
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // 5. Garis Pemisah (Or continue with)
  static Widget dividerOr() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Or continue with",
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ],
    );
  }
}
