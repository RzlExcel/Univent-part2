import 'package:flutter/material.dart';

class AppTheme {
  // ==========================================
  // 1. KOLEKSI WARNA UNIVENT
  // ==========================================
  static const Color primaryPink = Color(0xFFFE2B6E);
  static const Color gradientOrange = Color(0xFFFF5E5E);
  static const Color darkText = Color(0xFF1E212B);
  static const Color greyText = Colors.black54;
  static const Color backgroundLight = Color(0xFFF4F7FC);
  static const Color white = Colors.white;
  static const Color darkBlue = Color(0xFF0F172A);

  // Warna Badge / Status
  static const Color badgePendingBg = Color(0xFFFEF3C7);
  static const Color badgePendingText = Color(0xFFD97706);
  static const Color badgeGreenBg = Color(0xFFD1FAE5);
  static const Color badgeGreenText = Color(0xFF059669);
  static const Color badgeRedBg = Color(0xFFFEEDF2);
  static const Color badgeRedText = Color(0xFFFE2B6E);
  static const Color glowPink = Color(0xFFFF4081);

  // Warna Tambahan Khusus Elemen Profil & Kartu
  static const Color lightPinkBg = Color(0xFFFEEDF2);
  static const Color lightGreyBg = Color(0xFFF3F4F6);
  static const Color dividerColor = Color(0xFFE5E7EB);

  // ==========================================
  // 2. GAYA TULISAN (TYPOGRAPHY)
  // ==========================================
  static const TextStyle titleLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.8,
    color: darkText,
    height: 1.2,
  );

  static const TextStyle subtitleRegular = TextStyle(
    fontSize: 14,
    color: greyText,
    height: 1.5,
    fontWeight: FontWeight.w500,
  );

  // ==========================================
  // 3. GAYA TOMBOL
  // ==========================================
  static final ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: primaryPink,
    foregroundColor: white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );

  static final ButtonStyle outlineButton = OutlinedButton.styleFrom(
    foregroundColor: darkText,
    side: const BorderSide(color: Colors.black12),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
  );
}
