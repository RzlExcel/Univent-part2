import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class EoUpgradePage extends StatefulWidget {
  const EoUpgradePage({super.key});

  @override
  State<EoUpgradePage> createState() => _EoUpgradePageState();
}

class _EoUpgradePageState extends State<EoUpgradePage> {
  final _orgNameCtrl = TextEditingController();
  final _picNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();

  String _orgType = 'Internal Kampus'; // Default pilihan
  bool _isLoading = false;

  void _submitRequest() async {
    if (_orgNameCtrl.text.isEmpty ||
        _picNameCtrl.text.isEmpty ||
        _phoneCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap isi semua kolom wajib!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      "eo_org_type": _orgType,
      "eo_org_name": _orgNameCtrl.text,
      "eo_pic_name": _picNameCtrl.text,
      "eo_phone": _phoneCtrl.text,
      "eo_instagram": _instagramCtrl.text,
    };

    final result = await ApiAuthService.submitEoRequest(data);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));

      if (result['success'] == true) {
        Navigator.pop(
          context,
          true,
        ); // Kembali & beri sinyal true ke ProfilePage untuk direfresh
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pengajuan Akun EO",
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkBlue),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightPinkBg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppTheme.primaryPink),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Akun Event Organizer (EO) memungkinkan Anda untuk membuat dan memanajemen event di Univent.",
                          style: TextStyle(
                            color: AppTheme.darkBlue,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  "Tipe Organisasi",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _orgType,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  items: ['Internal Kampus', 'Eksternal Publik'].map((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) => setState(() => _orgType = newValue!),
                ),

                const SizedBox(height: 16),
                _buildInputField(
                  "Nama Organisasi / UKM",
                  _orgNameCtrl,
                  Icons.group_outlined,
                ),

                const SizedBox(height: 16),
                _buildInputField(
                  "Nama Penanggung Jawab (PIC)",
                  _picNameCtrl,
                  Icons.person_outline,
                ),

                const SizedBox(height: 16),
                _buildInputField(
                  "Nomor WhatsApp Aktif",
                  _phoneCtrl,
                  Icons.phone_outlined,
                  isNumber: true,
                ),

                const SizedBox(height: 16),
                _buildInputField(
                  "Link Instagram (Opsional)",
                  _instagramCtrl,
                  Icons.link,
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "KIRIM PENGAJUAN",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),

          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
