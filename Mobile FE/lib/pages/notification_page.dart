import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_notification_service.dart';
import 'admin_eo_request_page.dart';
import 'event_list_management_page.dart';
import 'event_history_page.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<Map<String, dynamic>> _notifFuture;

  @override
  void initState() {
    super.initState();
    _notifFuture = ApiNotificationService.getNotifications();
    // Otomatis tandai sudah dibaca saat halaman ini dibuka
    ApiNotificationService.markAllAsRead();
  }

  Future<void> _refresh() async {
    setState(() {
      _notifFuture = ApiNotificationService.getNotifications();
    });
  }

  String _stripHtmlIfNeeded(String text) {
    // Regex ini akan menghapus semua teks yang berada di dalam kurung kurawal < >
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Notifications",
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _notifFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          if (!snapshot.hasData || snapshot.data!['success'] == false) {
            return const Center(child: Text("Gagal memuat notifikasi."));
          }

          final List notifications = snapshot.data!['data'] ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 60,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Belum ada notifikasi",
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: AppTheme.primaryPink,
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isRead = notif['is_read'] == true;

                return Container(
                  color: isRead
                      ? Colors.white
                      : AppTheme.lightPinkBg.withOpacity(0.3),
                  child: ListTile(
                    onTap: () {
                      final type = notif['type'] ?? '';

                      // 1. Jika Notif Pengajuan EO -> Arahkan ke halaman Persetujuan Akun EO
                      if (type == 'NewEoRequestNotification') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AdminEoRequestPage(),
                          ),
                        );
                      }
                      // 2. Jika Notif Event Baru -> Arahkan ke halaman Event List Management
                      else if (type == 'NewEventSubmittedNotification') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            // Catatan: hapus 'const' jika EventListManagementPage tidak pakai const
                            builder: (context) => EventListManagementPage(),
                          ),
                        );
                      }
                      // 3. Jika Notif untuk User (Event di-ACC / EO di-ACC) -> Arahkan ke History
                      else if (type == 'EventStatusNotification' ||
                          type == 'EoRequestStatusNotification') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EventHistoryPage(),
                          ),
                        );
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isRead
                          ? Colors.grey.shade100
                          : AppTheme.lightPinkBg,
                      child: Icon(
                        Icons.notifications,
                        color: isRead ? Colors.grey : AppTheme.primaryPink,
                      ),
                    ),
                    title: Text(
                      notif['title'],
                      style: TextStyle(
                        fontWeight: isRead
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          _stripHtmlIfNeeded(
                            notif['message'],
                          ), // <--- Panggil fungsinya di sini
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          notif['created_at'],
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
