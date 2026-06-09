import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/edit_profile_kerangka.dart';
import '../services/auth_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _birthdayCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  File? _avatarFile;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // --- FUNGSI BUKA GALERI ---
  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
    }
  }

  // --- FUNGSI AMBIL DATA AWAL ---
  Future<void> _loadProfile() async {
    final result = await ApiAuthService.getUserProfile();
    if (result['success'] == true) {
      final user = result['user'];
      setState(() {
        _nameCtrl.text = user['name'] ?? '';
        _phoneCtrl.text = (user['phone'] == 'Belum diatur')
            ? ''
            : user['phone'];
        _birthdayCtrl.text = (user['birthday'] == 'Belum diatur')
            ? ''
            : user['birthday'];

        // Tarik foto lama dari database (Sesuaikan URL jika perlu)
        _currentAvatarUrl = user['avatar'] != null
            ? "http://10.0.2.2:8000/storage/${user['avatar']}"
            : null;

        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal memuat profil")));
    }
  }

  // --- FUNGSI SIMPAN DATA ---
  Future<void> _saveProfile() async {
    if (_nameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama lengkap wajib diisi!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Karena menggunakan form-data (gambar), valuenya wajib bertipe String semua
    final Map<String, String> data = {
      "name": _nameCtrl.text,
      "phone": _phoneCtrl.text,
      "birthday": _birthdayCtrl.text,
    };

    // Kirim data text sekaligus file gambar (jika ada)
    final result = await ApiAuthService.updateProfile(
      data,
      avatarFile: _avatarFile,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      if (result['success'] == true) {
        Navigator.pop(
          context,
          true,
        ); // Kembali & beri sinyal bahwa data berubah
      }
    }
  }

  // --- FUNGSI KALENDER ---
  Future<void> _selectBirthday() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950), // Batas tahun bawah
      lastDate: DateTime.now(), // Maksimal hari ini
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryPink),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        // Format YYYY-MM-DD agar dikenali oleh Laravel
        _birthdayCtrl.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              )
            else
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 40.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // --- FOTO PROFIL DINAMIS ---
                    EditProfileKerangka.profilePicture(
                      onTap: _pickAvatar,
                      imageFile: _avatarFile,
                      currentImageUrl: _currentAvatarUrl,
                      userName: _nameCtrl.text.isNotEmpty
                          ? _nameCtrl.text
                          : "Loading...",
                    ),

                    const SizedBox(height: 40),
                    EditProfileKerangka.formHeader(),
                    const SizedBox(height: 32),

                    // --- INPUT FIELDS ---
                    EditProfileKerangka.inputField(
                      label: "FULL NAME",
                      hint: "Masukkan nama lengkap",
                      icon: Icons.person_outline,
                      controller: _nameCtrl,
                    ),
                    const SizedBox(height: 20),

                    EditProfileKerangka.inputField(
                      label: "BIRTHDAY",
                      hint: "yyyy-mm-dd",
                      icon: Icons.cake_outlined,
                      suffixIcon: Icons.calendar_today_outlined,
                      controller: _birthdayCtrl,
                      readOnly: true,
                      onTap: _selectBirthday,
                    ),
                    const SizedBox(height: 20),

                    EditProfileKerangka.inputField(
                      label: "PHONE NUMBER",
                      hint: "08xxxxxxxxxx",
                      icon: Icons.phone_outlined,
                      controller: _phoneCtrl,
                    ),
                    const SizedBox(height: 40),

                    // --- TOMBOL CANCEL & SAVE ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryPink.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryPink,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    "SAVE CHANGES",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),

            // --- TOMBOL BACK DI KIRI ATAS ---
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
                  icon: const Icon(Icons.arrow_back, color: AppTheme.darkBlue),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
