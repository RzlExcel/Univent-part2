import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HistoryKerangka {
  // 1. Header Halaman History
  static Widget historyHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Event History",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.darkBlue),
        ),
        SizedBox(height: 4),
        Text(
          "Pantau status pendaftaran dan daftar event yang pernah kamu ikuti.",
          style: TextStyle(fontSize: 14, color: Colors.blueGrey),
        ),
      ],
    );
  }

  // 2. Kartu Riwayat Event (Versi Mobile)
  static Widget historyCard({
    required String title,
    required String date,
    required String id,
    required String status,
    required VoidCallback onDetailPressed,
  }) {
    // Logika warna status
    Color badgeColor = AppTheme.badgePendingBg;
    Color textColor = AppTheme.badgePendingText;

    if (status.toLowerCase() == 'approved') {
      badgeColor = AppTheme.badgeGreenBg;
      textColor = AppTheme.badgeGreenText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Icon Placeholder (Kotak Abu-abu di kiri)
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.image_outlined, color: Colors.grey.shade300),
          ),
          const SizedBox(width: 16),
          
          // Informasi Tengah
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.darkBlue),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(date, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.info_outline, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(id, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),

          // Bagian Kanan (Status & Tombol)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Badge Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              const SizedBox(height: 10),
              // Tombol Details Hitam
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onDetailPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.darkBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text("DETAILS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}