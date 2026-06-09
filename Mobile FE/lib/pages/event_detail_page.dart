import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/event_service.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;

  const EventDetailPage({super.key, required this.eventId});

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  final ApiEventService _eventService = ApiEventService();
  late Future<Map<String, dynamic>> _eventDetailFuture;

  @override
  void initState() {
    super.initState();
    _eventDetailFuture = _eventService.fetchEventDetail(widget.eventId);
  }

  // Fungsi pembantu untuk membuka link registrasi eksternal jika ada
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka link registrasi")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _eventDetailFuture,
      builder: (context, snapshot) {
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            ),
          );
        }

        // 2. Error State
        if (snapshot.hasError || snapshot.data?['success'] != true) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              iconTheme: const IconThemeData(color: AppTheme.darkBlue),
            ),
            body: Center(
              child: Text(
                snapshot.data?['message'] ?? "Gagal memuat detail event.",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        // 3. Success State - Ekstraksi Data dari Laravel
        final ev = snapshot.data!['data'];

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FA),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              onPressed: () {
                final link = ev['registration_link'] ?? '';
                if (link.isNotEmpty) {
                  _launchURL(link);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Link registrasi tidak tersedia"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                "REGISTER EVENT NOW",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BAGIAN POSTER / HEADER IMAGE ---
                Stack(
                  children: [
                    Container(
                      height: 320,
                      width: double.infinity,
                      color: AppTheme.darkBlue,
                      child:
                          (ev['event_poster'] != null &&
                              ev['event_poster'] != 'default_poster.png' &&
                              ev['event_poster'].toString().isNotEmpty)
                          ? Image.network(
                              "http://10.0.2.2:8000/storage/${ev['event_poster']}",
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stack) => const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 50,
                                ),
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.event,
                                color: Colors.white24,
                                size: 80,
                              ),
                            ),
                    ),
                    // Tombol Back bulat transparan bawaanmu
                    Positioned(
                      top: 50,
                      left: 20,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- BADGES KATEGORI ---
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (ev['category_name'] ?? "UMUM")
                                  .toString()
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.blue),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "EXTERNAL",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // --- TITLE ---
                      Text(
                        ev['event_title'] ?? "Tanpa Judul",
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // --- ORGANIZER ---
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          RichText(
                            text: TextSpan(
                              text: "Organized by ",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      ev['organizer_name'] ?? "UKM / Himpunan",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.darkBlue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- KARTU DETAIL INFORMASI ---
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "START DATE",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade300,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${ev['start_date'] ?? '-'}\n${ev['start_time'] ?? ''}",
                                        style: const TextStyle(
                                          color: AppTheme.darkText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "END DATE",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade300,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${ev['end_date'] ?? '-'}\n${ev['end_time'] ?? ''}",
                                        style: const TextStyle(
                                          color: AppTheme.darkText,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 14.0),
                              child: Divider(color: Color(0xFFEEEEEE)),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  color: AppTheme.primaryPink,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Location",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade300,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        ev['event_location'] ??
                                            "Belum ditentukan",
                                        style: const TextStyle(
                                          color: AppTheme.darkText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.call_outlined,
                                  color: AppTheme.primaryPink,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Contact Person",
                                        style: TextStyle(
                                          color: Colors.blueGrey.shade300,
                                          fontSize: 12,
                                        ),
                                      ),
                                      Text(
                                        ev['contact_person'] ?? "-",
                                        style: const TextStyle(
                                          color: AppTheme.darkText,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // --- KARTU ABOUT / DESKRIPSI ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "ABOUT EVENT",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              ev['event_description'] ??
                                  "Tidak ada deskripsi untuk event ini.",
                              style: const TextStyle(
                                color: Colors.grey,
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
