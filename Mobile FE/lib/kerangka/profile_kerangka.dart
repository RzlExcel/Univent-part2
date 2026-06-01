import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileKerangka {
  // 1. Kerangka Kotak Statistik
  static Widget statBox(String number, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(color: AppTheme.lightGreyBg, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(number, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  // 2. Kerangka Judul Bagian
  static Widget sectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.darkText)),
        Container(width: 32, height: 4, decoration: BoxDecoration(color: AppTheme.primaryPink, borderRadius: BorderRadius.circular(2))),
      ],
    );
  }

  // 3. Kerangka Baris Info Pribadi
  static Widget infoRow({required IconData icon, required Color iconColor, required Color bgColor, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12), 
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)), 
          child: Icon(icon, color: iconColor, size: 24)
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.greyText, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, color: AppTheme.darkText, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Kerangka Garis Pembatas
  static Widget divider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0), 
      child: Divider(color: AppTheme.dividerColor, height: 1)
    );
  }

  // 5. Kerangka Tombol Outline
  static Widget outlineButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16), 
          side: BorderSide(color: color == AppTheme.primaryPink ? color : Colors.black12, width: 1), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  // --- KERANGKA MENU DROPDOWN (DI DALAM KARTU) ---
  static Widget cardDropdownMenu(BuildContext context) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppTheme.white,
      elevation: 4,
      // Tampilannya sekarang cuma icon titik tiga yang elegan
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.lightGreyBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.more_horiz, color: AppTheme.darkText),
      ),
      // Isi Menu-nya tetap sama
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'profile',
          child: Text("My Profile", style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500)),
        ),
        const PopupMenuItem<String>(
          value: 'admin',
          child: Text("Admin Panel", style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.w500)),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text("Sign Out", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
      onSelected: (String value) {
        print("Menu diklik: $value");
      },
    );
  }
}