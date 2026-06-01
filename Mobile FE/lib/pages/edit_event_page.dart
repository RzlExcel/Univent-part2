import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/edit_event_kerangka.dart';
import '../services/event_service.dart';

class EditEventPage extends StatefulWidget {
  final int eventId; // Terima ID Event
  const EditEventPage({super.key, required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final ApiEventService _eventService = ApiEventService();
  bool _isLoading = true;

  // Controllers untuk Input Teks
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _orgNameCtrl = TextEditingController();
  final TextEditingController _startDateCtrl = TextEditingController();
  final TextEditingController _startTimeCtrl = TextEditingController();
  final TextEditingController _endDateCtrl = TextEditingController();
  final TextEditingController _endTimeCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _locationCtrl = TextEditingController();
  final TextEditingController _contactCtrl = TextEditingController();
  final TextEditingController _linkCtrl = TextEditingController();

  // Variabel untuk Dropdown
  String? _selectedOrganizerType;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadEventData(); // Ambil data lama saat masuk halaman
  }

  // --- FUNGSI AMBIL DATA DARI LARAVEL ---
  void _loadEventData() async {
    final result = await _eventService.fetchEventDetail(widget.eventId);
    if (result['success'] == true) {
      final data = result['data'];
      setState(() {
        _titleCtrl.text = data['event_title'] ?? '';
        _orgNameCtrl.text = data['organizer_name'] ?? '';
        _startDateCtrl.text = data['start_date'] ?? '';
        _startTimeCtrl.text = data['start_time'] ?? '';
        _endDateCtrl.text = data['end_date'] ?? '';
        _endTimeCtrl.text = data['end_time'] ?? '';
        _descCtrl.text = data['event_description'] ?? '';
        _locationCtrl.text = data['event_location'] ?? '';
        _contactCtrl.text = data['contact_person'] ?? '';
        _linkCtrl.text = data['registration_link'] ?? '';

        // Penyesuaian nilai dropdown dengan data dari database
        final type = data['organizer_type'];
        if (['Student Association', 'Lecturer', 'External'].contains(type)) {
          _selectedOrganizerType = type;
        }

        final cat = data['category_name'];
        if (['Seminar', 'Workshop', 'Competition', 'Gathering'].contains(cat)) {
          _selectedCategory = cat;
        }

        _isLoading = false;
      });
    }
  }

  // --- FUNGSI UPDATE DATA ---
  void _handleUpdate() async {
    setState(() => _isLoading = true);
    Map<String, dynamic> data = {
      'event_title': _titleCtrl.text,
      'organizer_name': _orgNameCtrl.text,
      'organizer_type': _selectedOrganizerType, // Masukkan data dropdown
      'category_id': _selectedCategory == 'Seminar'
          ? 1
          : 2, // Sesuaikan id kategori
      'start_date': _startDateCtrl.text,
      'start_time': _startTimeCtrl.text,
      'end_date': _endDateCtrl.text,
      'end_time': _endTimeCtrl.text,
      'event_description': _descCtrl.text,
      'event_location': _locationCtrl.text,
      'contact_person': _contactCtrl.text,
      'registration_link': _linkCtrl.text,
    };

    final res = await _eventService.updateEvent(widget.eventId, data);
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'])));
      if (res['success'] == true) Navigator.pop(context, true);
    }
  }

  // --- FUNGSI DATE & TIME PICKER ---
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryPink),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
        () => controller.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",
      );
    }
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryPink),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(
        () => controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryPink),
        ),
      );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Edit Event",
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
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
                "Update your event information below.",
                style: TextStyle(color: Colors.blueGrey, fontSize: 13),
              ),
              const SizedBox(height: 32),

              EditEventKerangka.fieldLabel("Event Title"),
              EditEventKerangka.inputField(
                hint: "Enter title",
                controller: _titleCtrl,
              ),
              const SizedBox(height: 20),

              EditEventKerangka.fieldLabel("Organizer Name"),
              EditEventKerangka.inputField(
                hint: "Enter organizer",
                controller: _orgNameCtrl,
              ),
              const SizedBox(height: 20),

              // --- DROPDOWNS ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditEventKerangka.fieldLabel("Organizer Type"),
                        EditEventKerangka.dropdownField(
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
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditEventKerangka.fieldLabel("Event Category"),
                        EditEventKerangka.dropdownField(
                          hint: "Select category",
                          value: _selectedCategory,
                          items: [
                            'Seminar',
                            'Workshop',
                            'Competition',
                            'Gathering',
                          ],
                          onChanged: (val) =>
                              setState(() => _selectedCategory = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- SCHEDULE DENGAN PICKER ---
              const Text(
                "EVENT SCHEDULE",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: EditEventKerangka.inputField(
                      hint: "yyyy-mm-dd",
                      icon: Icons.calendar_today,
                      controller: _startDateCtrl,
                      readOnly: true,
                      onTap: () => _selectDate(_startDateCtrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EditEventKerangka.inputField(
                      hint: "--:--",
                      icon: Icons.access_time,
                      controller: _startTimeCtrl,
                      readOnly: true,
                      onTap: () => _selectTime(_startTimeCtrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: EditEventKerangka.inputField(
                      hint: "yyyy-mm-dd",
                      icon: Icons.calendar_today,
                      controller: _endDateCtrl,
                      readOnly: true,
                      onTap: () => _selectDate(_endDateCtrl),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: EditEventKerangka.inputField(
                      hint: "--:--",
                      icon: Icons.access_time,
                      controller: _endTimeCtrl,
                      readOnly: true,
                      onTap: () => _selectTime(_endTimeCtrl),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- DESCRIPTION ---
              EditEventKerangka.fieldLabel("Description"),
              EditEventKerangka.inputField(
                hint: "Enter description",
                maxLines: 4,
                controller: _descCtrl,
              ),
              const SizedBox(height: 20),

              // --- LOCATION & CONTACT ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditEventKerangka.fieldLabel("Location"),
                        EditEventKerangka.inputField(
                          hint: "Location",
                          controller: _locationCtrl,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EditEventKerangka.fieldLabel("Contact Person"),
                        EditEventKerangka.inputField(
                          hint: "Contact",
                          controller: _contactCtrl,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // --- REGISTRATION LINK ---
              EditEventKerangka.fieldLabel("Registration Link"),
              EditEventKerangka.inputField(
                hint: "https://...",
                controller: _linkCtrl,
              ),
              const SizedBox(height: 20),

              // --- POSTER UPLOAD ---
              EditEventKerangka.fieldLabel("Event Poster"),
              EditEventKerangka.uploadPosterBox(), // Nanti bisa dipasangkan fungsi Image Picker seperti di SubmitEvent
              const SizedBox(height: 40),

              // --- TOMBOL UPDATE ---
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Update Event",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
