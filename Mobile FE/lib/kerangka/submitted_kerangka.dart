import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubmittedKerangka {
  // KARTU EVENT KHUSUS ADMIN (ADA TOMBOL ACCEPT, REJECT, VIEW, DELETE)
  static Widget adminEventCard({
    required String title,
    required String organizer,
    required String status,
    required VoidCallback onAccept,
    required VoidCallback onReject,
    required VoidCallback onView,
    required VoidCallback onDelete,
  }) {
    // Logika warna status
    Color badgeColor = AppTheme.badgePendingBg;
    Color textColor = AppTheme.badgePendingText;

    if (status.toLowerCase() == 'disetujui') {
      badgeColor = AppTheme.badgeGreenBg;
      textColor = AppTheme.badgeGreenText;
    } else if (status.toLowerCase() == 'ditolak') {
      badgeColor = AppTheme.badgeRedBg;
      textColor = AppTheme.badgeRedText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // --- BAGIAN ATAS (INFO EVENT & STATUS) ---
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gambar Event (Placeholder)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_outlined, color: Colors.grey.shade300),
              ),
              const SizedBox(width: 16),
              
              // Judul & Organizer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.darkBlue),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "BY ${organizer.toUpperCase()}",
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
              
              // Badge Status PENDING / DISETUJUI
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ],
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(color: AppTheme.dividerColor, height: 1),
          ),

          // --- BAGIAN BAWAH (4 TOMBOL AKSI ADMIN) ---
          Row(
            mainAxisAlignment: MainAxisAlignment.end, // Posisi tombol di kanan
            children: [
              // 1. Tombol Accept (Centang Hijau)
              _actionButton(
                icon: Icons.check, 
                color: Colors.green, 
                bgColor: Colors.green.shade50, 
                onTap: onAccept
              ),
              const SizedBox(width: 12),
              
              // 2. Tombol Reject (Silang Merah)
              _actionButton(
                icon: Icons.close, 
                color: Colors.redAccent, 
                bgColor: Colors.red.shade50, 
                onTap: onReject
              ),
              const SizedBox(width: 12),
              
              // 3. Tombol View (Mata Abu-abu)
              _actionButton(
                icon: Icons.visibility_outlined, 
                color: Colors.blueGrey, 
                bgColor: Colors.grey.shade100, 
                onTap: onView
              ),
              const SizedBox(width: 12),
              
              // 4. Tombol Delete (Tong Sampah Abu-abu)
              _actionButton(
                icon: Icons.delete_outline, 
                color: Colors.blueGrey, 
                bgColor: Colors.grey.shade100, 
                onTap: onDelete
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget Pembantu untuk membuat tombol bulat
  static Widget _actionButton({required IconData icon, required Color color, required Color bgColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}