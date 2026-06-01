import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SubmitKerangka {
  // 1. Kerangka Label dengan Bintang Merah
  static Widget formLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppTheme.darkText,
        ), // Atau pakai AppTheme.darkBlue kalau ada
        children: const [
          TextSpan(
            text: ' *',
            style: TextStyle(color: AppTheme.primaryPink),
          ),
        ],
      ),
    );
  }

  // 2. Kerangka Input Field (Ditambah parameter controller)
  static Widget inputField({
    required String label,
    required String hint,
    int maxLines = 1,
    IconData? icon,
    TextEditingController? controller,
    bool readOnly = false, // <--- TAMBAHAN
    VoidCallback? onTap, // <--- TAMBAHAN // <--- TAMBAHAN
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        formLabel(label),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // <--- PASANGKAN DI SINI
          maxLines: maxLines,
          readOnly: readOnly, // <--- PASANG DI SINI
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            suffixIcon: icon != null
                ? Icon(icon, color: Colors.grey, size: 20)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryPink),
            ),
            filled: true,
            fillColor: Colors.white, // Pastikan background form putih
          ),
        ),
      ],
    );
  }

  // 3. Kerangka Dropdown (Tetap sama)
  static Widget dropdownField({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        formLabel(label),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text(
                hint,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              value: value,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: items
                  .map(
                    (String item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 14)),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // 4. Form Description dengan Tombol AI (Ditambah controller dan fungsi klik)
  static Widget descriptionWithAIField({
    required String label,
    required String hint,
    int maxLines = 4,
    TextEditingController? controller, // <--- TAMBAHAN CONTROLLER
    VoidCallback? onAIPressed, // <--- TAMBAHAN FUNGSI KLIK
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            formLabel(label),
            // Tombol Generate AI yang sekarang bisa diklik
            InkWell(
              onTap: onAIPressed, // <--- PASANGKAN FUNGSI KLIK
              borderRadius: BorderRadius.circular(
                12,
              ), // Biar efek kliknya melengkung
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      "Generate with AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // <--- PASANGKAN DI SINI
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.primaryPink),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  // 5. Kerangka Kotak Upload Poster (Tetap sama)
  static Widget uploadBox({VoidCallback? onTap, String? fileName}) {
    // <--- TAMBAHAN PARAMETER
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        formLabel("Event Poster"),
        const SizedBox(height: 8),
        InkWell(
          // <--- BUNGKUS DENGAN INKWELL AGAR BISA DIKLIK
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  fileName != null
                      ? Icons.image
                      : Icons
                            .file_upload_outlined, // Ikon berubah jika file terpilih
                  color: AppTheme.primaryPink,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  fileName ??
                      "Tap here to select an image from gallery", // <--- TEKS BERUBAH
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "PNG, JPG up to 4MB",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
