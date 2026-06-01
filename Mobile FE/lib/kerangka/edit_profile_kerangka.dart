import 'dart:io'; // <--- WAJIB DITAMBAHKAN UNTUK MEMBACA FILE FOTO
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EditProfileKerangka {
  // 1. Foto Profil dengan Glow Pink & Nama (Sudah Dinamis)
  static Widget profilePicture({
    VoidCallback? onTap,
    File? imageFile,
    String? currentImageUrl,
    String userName = "User", // <--- Tambahan agar nama bisa berubah
  }) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap, // <--- Agar foto bisa di-klik
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPink.withOpacity(0.3),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                  // Menampilkan gambar dari galeri atau server
                  image: imageFile != null
                      ? DecorationImage(
                          image: FileImage(imageFile),
                          fit: BoxFit.cover,
                        )
                      : (currentImageUrl != null && currentImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(currentImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                // Menampilkan icon default HANYA jika tidak ada foto sama sekali
                child:
                    (imageFile == null &&
                        (currentImageUrl == null || currentImageUrl.isEmpty))
                    ? const Icon(Icons.person, size: 60, color: Colors.white)
                    : null,
              ),

              // Icon kamera kecil di pojok kanan bawah foto
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          userName, // <--- Nama dinamis dari database
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "UPDATE PHOTO",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }

  // 2. Header Form
  static Widget formHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "EDIT PERSONAL INFORMATION",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Sesuaikan profilmu agar orang lain lebih mudah mengenalimu.",
          style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade400),
        ),
      ],
    );
  }

  // 3. Input Field Edit Profile
  static Widget inputField({
    required String label,
    required String hint,
    required IconData icon,
    IconData? suffixIcon,
    TextEditingController? controller,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppTheme.darkBlue,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, color: Colors.blueGrey.shade300, size: 20),
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: AppTheme.darkBlue, size: 20)
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.primaryPink),
            ),
          ),
        ),
      ],
    );
  }
}
