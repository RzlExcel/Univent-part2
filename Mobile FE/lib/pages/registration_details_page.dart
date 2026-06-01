import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/register_kerangka.dart';
import 'edit_event_page.dart';
import '../services/event_service.dart';

class RegistrationDetailsPage extends StatefulWidget {
  final int eventId; // <--- MENERIMA ID EVENT DARI HALAMAN SEBELUMNYA

  const RegistrationDetailsPage({super.key, required this.eventId});

  @override
  State<RegistrationDetailsPage> createState() =>
      _RegistrationDetailsPageState();
}

class _RegistrationDetailsPageState extends State<RegistrationDetailsPage> {
  final ApiEventService _eventService = ApiEventService();
  late Future<Map<String, dynamic>> _eventDetailFuture;

  @override
  void initState() {
    super.initState();
    _eventDetailFuture = _eventService.fetchEventDetail(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _eventDetailFuture,
          builder: (context, snapshot) {
            // Tampilan saat loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              );
            }

            // Tampilan saat error
            if (snapshot.hasError || snapshot.data?['success'] != true) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      snapshot.data?['message'] ?? "Gagal memuat data",
                      style: const TextStyle(color: Colors.red),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Kembali"),
                    ),
                  ],
                ),
              );
            }

            // Data berhasil ditangkap
            final ev = snapshot.data?['data'] ?? {};
            final status = (ev['status'] ?? 'PENDING').toString().toUpperCase();

            // Atur warna badge status
            Color badgeColor = AppTheme.badgePendingBg;
            Color textColor = AppTheme.badgePendingText;
            if (status == 'APPROVED') {
              badgeColor = Colors.green.shade50;
              textColor = Colors.green;
            } else if (status == 'REJECTED') {
              badgeColor = Colors.red.shade50;
              textColor = Colors.red;
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- 1. HEADER NAVIGASI ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.arrow_back,
                          size: 16,
                          color: AppTheme.darkBlue,
                        ),
                        label: const Text(
                          "Back",
                          style: TextStyle(
                            color: AppTheme.darkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditEventPage(eventId: widget.eventId),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.edit,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: const Text(
                          "Edit Submission",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(color: AppTheme.dividerColor, height: 1),
                  ),

                  // --- 2. KARTU PUTIH UTAMA ---
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
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
                        // Bagian Sub-Header & Status Badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "REGISTRATION DETAILS",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.darkBlue,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "SUBMISSION ID: #REG-${ev['id'] ?? '-'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade100),
                        const SizedBox(height: 24),

                        if (ev['event_poster'] != null &&
                            ev['event_poster'].toString().isNotEmpty)
                          Container(
                            width: double.infinity,
                            height: 220,
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.grey.shade100,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                "http://10.0.2.2:8000/storage/${ev['event_poster']}",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          "Gagal memuat poster",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                              ),
                            ),
                          ),

                        // DATA DINAMIS DARI DATABASE
                        RegistrasiKerangka.eventTitle(
                          ev['event_title'] ?? "Tanpa Judul",
                          ev['category_name'] ?? "Kategori",
                          ev['organizer_type'] ?? "TYPE",
                        ),
                        const SizedBox(height: 30),
                        RegistrasiKerangka.organizerBox(
                          ev['organizer_name'] ?? "Nama Penyelenggara",
                          "EVENT HOLDER",
                        ),
                        const SizedBox(height: 30),
                        RegistrasiKerangka.scheduleBox(
                          ev['start_date'] ?? "-",
                          ev['start_time'] ?? "-",
                          ev['end_date'] ?? "-",
                          ev['end_time'] ?? "-",
                        ),
                        const SizedBox(height: 30),
                        RegistrasiKerangka.infoRow(
                          Icons.location_on,
                          "LOCATION",
                          ev['event_location'] ?? "Belum ditentukan",
                        ),
                        const SizedBox(height: 20),
                        RegistrasiKerangka.infoRow(
                          Icons.link,
                          "REGISTRATION LINK",
                          ev['registration_link'] ?? "-",
                          isLink: true,
                        ),
                        const SizedBox(height: 20),
                        RegistrasiKerangka.infoRow(
                          Icons.phone,
                          "CONTACT PERSON",
                          ev['contact_person'] ?? "-",
                        ),
                        const SizedBox(height: 30),

                        // Deskripsi Event
                        RegistrasiKerangka.sectionLabel("EVENT DESCRIPTION"),
                        const SizedBox(height: 12),
                        Text(
                          ev['event_description'] ?? "-",
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkBlue,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
