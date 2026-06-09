import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/contact_kerangka.dart';
import '../services/auth_service.dart';
import '../services/contact_service.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  // 1. Buat Controller untuk masing-masing inputan
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _autoFillUserData(); // Panggil fungsi penarik data saat halaman dibuka
  }

  // 2. Fungsi untuk menarik data profil dan mengisinya ke Controller
  Future<void> _autoFillUserData() async {
    final result = await ApiAuthService.getUserProfile();

    if (mounted && result['success'] == true) {
      setState(() {
        // Isi otomatis controller dengan data dari database
        _nameController.text = result['user']['name'] ?? '';
        _emailController.text = result['user']['email'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    // 3. Bersihkan memori saat halaman ditutup
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Contact Us",
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Have questions or feedback? We'd love to hear from you!",
              style: TextStyle(
                fontSize: 14,
                color: Colors.blueGrey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // --- 1. KARTU INFORMASI KONTAK ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Get In Touch",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ContactKerangka.infoCard(
                    icon: Icons.location_on_outlined,
                    iconColor: Colors.redAccent,
                    bgColor: Colors.red.shade50,
                    title: "Address",
                    subtitle:
                        "Jl. D.I. Panjaitan No. 128, Purwokerto, Banyumas, Jawa Tengah",
                  ),
                  ContactKerangka.infoCard(
                    icon: Icons.phone_outlined,
                    iconColor: Colors.green,
                    bgColor: Colors.green.shade50,
                    title: "WhatsApp",
                    subtitle: "087824253296",
                  ),
                  ContactKerangka.infoCard(
                    icon: Icons.mail_outline,
                    iconColor: AppTheme.primaryPink,
                    bgColor: AppTheme.lightPinkBg,
                    title: "Email Address",
                    subtitle: "univenttelkom@gmail.com",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. KARTU FORMULIR PESAN ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Send a Message",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 24),

                  ContactKerangka.formLabel("Your Name"),
                  // 👇 4. Pasang Controller di sini 👇
                  ContactKerangka.inputField(
                    hint: "Nama Anda",
                    controller: _nameController,
                  ),
                  const SizedBox(height: 20),

                  ContactKerangka.formLabel("Email Address"),
                  // 👇 Pasang Controller di sini 👇
                  ContactKerangka.inputField(
                    hint: "email@anda.com",
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),

                  ContactKerangka.formLabel("Message"),
                  // 👇 Pasang Controller di sini 👇
                  ContactKerangka.inputField(
                    hint: "Write your message here",
                    maxLines: 5,
                    controller: _messageController,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. Logika Validasi Sederhana
                        if (_messageController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Pesan tidak boleh kosong!"),
                            ),
                          );
                          return;
                        }

                        // 2. Tampilkan indikator sedang mengirim
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Mengirim pesan..."),
                            duration: Duration(seconds: 1), // Muncul sebentar
                          ),
                        );

                        // 3. Tembak API kirim pesan di sini
                        final result = await ApiContactService.sendMessage(
                          _nameController.text,
                          _emailController.text,
                          _messageController.text,
                        );

                        // 4. Tangani balasan dari server
                        if (context.mounted) {
                          // Tampilkan pesan sukses/gagal dari server
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result['message'])),
                          );

                          // Bersihkan kolom pesan JIKA sukses
                          if (result['success'] == true) {
                            _messageController.clear();
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryPink,
                        foregroundColor:
                            Colors.white, // Ini yang bikin teks jadi putih
                        elevation: 4,
                        shadowColor: AppTheme.primaryPink.withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            12,
                          ), // Sesuaikan dengan kotak input
                        ),
                      ),
                      child: const Text(
                        "Send Message",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- 3. SUPPORT HOURS BADGE ---
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  "SUPPORT HOURS: 08:00 - 17:00 WIB",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade400,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
