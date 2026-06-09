import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/event_service.dart';
import 'registration_details_page.dart'; // <--- 1. TAMBAHKAN IMPORT INI

class EventHistoryPage extends StatefulWidget {
  const EventHistoryPage({super.key});

  @override
  State<EventHistoryPage> createState() => _EventHistoryPageState();
}

class _EventHistoryPageState extends State<EventHistoryPage> {
  final ApiEventService _eventService = ApiEventService();
  late Future<Map<String, dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _eventService.fetchEventHistory();
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
          "Event History",
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _historyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          if (snapshot.hasError || snapshot.data?['success'] != true) {
            return Center(
              child: Text(
                snapshot.data?['message'] ?? "Gagal memuat riwayat event.",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final List events = snapshot.data?['data'] ?? [];

          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada riwayat pendaftaran event.",
                    style: TextStyle(color: AppTheme.greyText, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final ev = events[index];
              return _buildHistoryCard(
                title: ev['title'] ?? '-',
                organizer: ev['organizer'] ?? '-',
                date: ev['date'] ?? '-',
                status: ev['status'] ?? 'pending',
                // 👇 2. PASANG NAVIGASI DI SINI 👇
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RegistrationDetailsPage(eventId: ev['id']),
                    ),
                  ).then((_) {
                    // Refresh data otomatis kalau user kembali dari halaman detail/edit
                    setState(() {
                      _historyFuture = _eventService.fetchEventHistory();
                    });
                  });
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryCard({
    required String title,
    required String organizer,
    required String date,
    required String status,
    required VoidCallback onTap, // <--- 3. TAMBAHKAN PARAMETER KLIK
  }) {
    Color statusColor = Colors.orange;
    Color bgColor = Colors.orange.shade50;

    if (status.toLowerCase() == 'approved') {
      statusColor = Colors.green;
      bgColor = Colors.green.shade50;
    } else if (status.toLowerCase() == 'rejected') {
      statusColor = Colors.red;
      bgColor = Colors.red.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        // <--- 4. BUNGKUS KARTU DENGAN INKWELL AGAR BISA DIKETUK
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.lightPinkBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: AppTheme.primaryPink,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Oleh: $organizer",
                      style: const TextStyle(
                        color: AppTheme.greyText,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
