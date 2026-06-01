import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SignUpKerangka {
  // 1. Header (Create Account & Log In link)
  static Widget headerSection(VoidCallback onLoginPressed) {
    return Column(
      children: [
        const Text(
          "Create Account",
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
              "Already have an account? ",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            GestureDetector(
              onTap: onLoginPressed,
              child: const Text(
                "Log In",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 2. Input Field (Khusus Sign Up)
  static Widget inputField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    IconData? suffixIcon,
    TextEditingController? controller,
  }) {
    // Variabel state lokal
    bool isHidden = isPassword;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
                fontSize: 14,
              ),
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
                          setState(() {
                            isHidden = !isHidden;
                          });
                        },
                      )
                    : (suffixIcon != null
                          ? Icon(
                              suffixIcon,
                              color: Colors.grey.shade400,
                              size: 20,
                            )
                          : null),

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
}
