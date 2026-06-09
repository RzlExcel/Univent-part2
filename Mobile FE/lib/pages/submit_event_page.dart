import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/submit_kerangka.dart';
import '../services/event_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class SubmitEventPage extends StatefulWidget {
  const SubmitEventPage({super.key});

  @override
  State<SubmitEventPage> createState() => _SubmitEventPageState();
}

class _SubmitEventPageState extends State<SubmitEventPage> {
  final ApiEventService _eventService = ApiEventService();
  bool _isLoading = false;

  // --- CONTROLLER UNTUK MENANGKAP INPUTAN ---
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _startTimeCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _endTimeCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();
  final TextEditingController _categoryInputCtrl = TextEditingController();

  File? _posterFile;
  String? _posterFileName;
  String? _selectedOrganizerType;
  String? _selectedCategory;

  // --- FUNGSI SUBMIT KE API ---
  void _submitData() async {
    // 1. Validasi Kolom Wajib
    if (_titleCtrl.text.isEmpty ||
        _categoryInputCtrl.text.isEmpty ||
        _selectedCategory == null ||
        _startDateCtrl.text.isEmpty ||
        _descCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Judul, Kategori, Tanggal Mulai, dan Deskripsi wajib diisi!",
          ),
        ),
      );
      return;
    }

    // Nyalakan loading
    setState(() => _isLoading = true);

    try {
      // 👇 LOGIKA ADAPTASI MENGIKUTI ATURAN WEB 👇
      String categoryId = "other";
      String? newCategoryName;

      // Kita buat variabel untuk membaca teks asli yang tertera di kotak inputan
      String kategoriTeks = _categoryInputCtrl.text.trim();

      if (kategoriTeks == 'Seminar') {
        categoryId = "1";
      } else if (kategoriTeks == 'Workshop') {
        categoryId = "2";
      } else if (kategoriTeks == 'Competition') {
        categoryId = "3";
      } else if (kategoriTeks == 'Gathering') {
        categoryId = "4";
      } else if (kategoriTeks.isNotEmpty) {
        // Jika teks yang diketik di luar 4 menu di atas (Misal: "makan makan")
        categoryId = "other";
        newCategoryName = kategoriTeks;
      }

      // 2. Siapkan data JSON (WAJIB String semua karena kita mengirim File gambar)
      Map<String, String> data = {
        'event_title': _titleCtrl.text,
        'category_id': categoryId, // 👈 Mengirim ID Angka atau string "other"
        'start_date': _startDateCtrl.text,
        'event_description': _descCtrl.text,
        'event_location': _locationCtrl.text,
        'contact_person': _contactCtrl.text,
        'registration_link': _linkCtrl.text,
        'organizer_type': _selectedOrganizerType ?? 'UKM / Himpunan',
      };

      // Jika ada kategori kustom, selipkan parameternya ke dalam data payload
      if (newCategoryName != null) {
        data['new_category_name'] = newCategoryName;
      }
      // 👆 BATAS ADAPTASI LOGIKA WEB 👆

      // Tambahkan opsional hanya jika tidak kosong
      if (_startTimeCtrl.text.isNotEmpty)
        data['start_time'] = _startTimeCtrl.text;
      if (_endDateCtrl.text.isNotEmpty) data['end_date'] = _endDateCtrl.text;
      if (_endTimeCtrl.text.isNotEmpty) data['end_time'] = _endTimeCtrl.text;

      // 3. Kirim via Service (Sertakan juga posternya)
      final result = await _eventService.submitEvent(
        data,
        posterFile: _posterFile,
      );

      // 4. Matikan Loading jika selesai
      if (mounted) {
        setState(() => _isLoading = false);

        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Event berhasil disubmit!")),
          );
          _clearForm();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Gagal submit')),
          );
        }
      }
    } catch (e) {
      // JIKA ADA ERROR APAPUN, LOADING HARUS TETAP DIMATIKAN!
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Sistem Error: $e")));
      }
    }
  }

  // --- FUNGSI CLEAR FORM ---
  void _clearForm() {
    _titleCtrl.clear();
    _descCtrl.clear();
    _startDateCtrl.clear();
    _startTimeCtrl.clear();
    _endDateCtrl.clear();
    _endTimeCtrl.clear();
    _locationCtrl.clear();
    _contactCtrl.clear();
    _linkCtrl.clear();
    _categoryInputCtrl.clear();
    setState(() {
      _selectedCategory = null;
      _selectedOrganizerType = null;
      _posterFile = null;
      _posterFileName = null;
    });
  }

  // --- FUNGSI DATE PICKER (KALENDER) ---
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryPink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- FUNGSI TIME PICKER (JAM) ---
  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primaryPink),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  // --- FUNGSI IMAGE PICKER (GALERI) ---
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );

    if (image != null) {
      setState(() {
        _posterFile = File(image.path);
        _posterFileName = image.name;
      });
    }
  }

  // --- FUNGSI GENERATE AI ---
  void _generateAIDescription() async {
    // 1. Cek isi kotak inputan controller kategori biar anti-lolos
    if (_titleCtrl.text.trim().isEmpty ||
        _categoryInputCtrl.text.trim().isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1B2027),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: const Text(
            "Mohon isi 'Event Title' dan pilih/ketik 'Event Category' terlebih dahulu agar AI bisa bekerja maksimal!",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB3D4FF),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "OK",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Nyalakan Loading Layar
    setState(() => _isLoading = true);

    try {
      // 3. Panggil kurir service menembak Laravel Gemini
      final response = await _eventService.generateAiDescription(
        _titleCtrl.text.trim(),
        _categoryInputCtrl.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isLoading = false; // Matikan loading

          if (response['success'] == true) {
            // 👇 BERHASIL! Masukkan teks balasan Gemini ke kotak deskripsi
            _descCtrl.text = response['description'] ?? '';
          } else {
            // Tampilkan pesan error jika server/Gemini bermasalah
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  response['message'] ?? 'Gagal generate deskripsi',
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = true);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Koneksi AI Error: $e")));
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _startDateCtrl.dispose();
    _startTimeCtrl.dispose();
    _endDateCtrl.dispose();
    _endTimeCtrl.dispose();
    _locationCtrl.dispose();
    _contactCtrl.dispose();
    _linkCtrl.dispose();
    _categoryInputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const Text(
                  "Submit Event",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.darkText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: const TextSpan(
                    text: 'Share your event with the ',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                    children: [
                      TextSpan(
                        text: 'Telkom University',
                        style: TextStyle(
                          color: AppTheme.primaryPink,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' community'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- KOTAK FORM PUTIH ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SubmitKerangka.inputField(
                        label: "Event Title",
                        hint: "Enter Event Title",
                        controller: _titleCtrl,
                      ),
                      const SizedBox(height: 20),

                      // Dropdowns Row
                      Row(
                        children: [
                          Expanded(
                            child: SubmitKerangka.dropdownField(
                              label: "Organizer Type",
                              hint: "Select type",
                              value: _selectedOrganizerType,
                              items: [
                                'Student Association',
                                'Lecturer',
                                'External',
                              ],
                              onChanged: (val) =>
                                  setState(() => _selectedOrganizerType = val),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Event Category *",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    return DropdownMenu<String>(
                                      width: constraints
                                          .maxWidth, // Mengikuti lebar kolom
                                      hintText: "Select category",
                                      requestFocusOnTap:
                                          true, // 👈 MEMBUAT KEYBOARD BISA MUNCUL
                                      enableFilter:
                                          true, // 👈 BISA MENYARING KETIKAN
                                      controller:
                                          _categoryInputCtrl, // 👈 MENANGKAP KETIKAN KUSTOM
                                      inputDecorationTheme:
                                          InputDecorationTheme(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 14,
                                                  horizontal: 16,
                                                ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: BorderSide(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              borderSide: const BorderSide(
                                                color: AppTheme.primaryPink,
                                              ),
                                            ),
                                          ),
                                      dropdownMenuEntries: const [
                                        DropdownMenuEntry(
                                          value: 'Seminar',
                                          label: 'Seminar',
                                        ),
                                        DropdownMenuEntry(
                                          value: 'Workshop',
                                          label: 'Workshop',
                                        ),
                                        DropdownMenuEntry(
                                          value: 'Competition',
                                          label: 'Competition',
                                        ),
                                        DropdownMenuEntry(
                                          value: 'Gathering',
                                          label: 'Gathering',
                                        ),
                                      ],
                                      onSelected: (val) {
                                        setState(() => _selectedCategory = val);
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // EVENT SCHEDULE
                      const Text(
                        "EVENT SCHEDULE",
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: AppTheme.darkText,
                          letterSpacing: 1.2,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SubmitKerangka.inputField(
                              label: "Start Date",
                              hint: "yyyy-mm-dd",
                              icon: Icons.calendar_today_outlined,
                              controller: _startDateCtrl,
                              readOnly: true,
                              onTap: () => _selectDate(_startDateCtrl),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SubmitKerangka.inputField(
                              label: "Start Time",
                              hint: "--:-- --",
                              icon: Icons.access_time,
                              controller: _startTimeCtrl,
                              readOnly: true,
                              onTap: () => _selectTime(_startTimeCtrl),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: SubmitKerangka.inputField(
                              label: "End Date",
                              hint: "yyyy-mm-dd",
                              icon: Icons.calendar_today_outlined,
                              controller: _endDateCtrl,
                              readOnly: true,
                              onTap: () => _selectDate(_endDateCtrl),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: SubmitKerangka.inputField(
                              label: "End Time",
                              hint: "--:-- --",
                              icon: Icons.access_time,
                              controller: _endTimeCtrl,
                              readOnly: true,
                              onTap: () => _selectTime(_endTimeCtrl),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // DESCRIPTION + TOMBOL AI
                      SubmitKerangka.descriptionWithAIField(
                        label: "Description",
                        hint: "Describe your event...",
                        controller: _descCtrl,
                        onAIPressed: _generateAIDescription,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // SISA FORM (Lokasi, Link, Poster dkk)
                Row(
                  children: [
                    Expanded(
                      child: SubmitKerangka.inputField(
                        label: "Location",
                        hint: "Enter Location",
                        controller: _locationCtrl,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: SubmitKerangka.inputField(
                        label: "Contact Person",
                        hint: "Name (WhatsApp)",
                        controller: _contactCtrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SubmitKerangka.inputField(
                  label: "Registration Link",
                  hint: "https://...",
                  controller: _linkCtrl,
                ),
                const SizedBox(height: 30),

                // Upload Poster
                SubmitKerangka.uploadBox(
                  onTap: _pickImage,
                  fileName: _posterFileName,
                ),

                // BUTTONS
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : _clearForm,
                      child: const Text(
                        "Clear Form",
                        style: TextStyle(
                          color: AppTheme.darkText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitData,
                      style: AppTheme.primaryButton,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          _isLoading ? "Submitting..." : "Submit Event",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Layer Loading Hitam Transparan
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              ),
            ),
        ],
      ),
    );
  }
}
