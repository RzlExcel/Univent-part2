import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart'; // 👈 1. Wajib ditambah
import 'pages/home_page.dart';
import 'services/firebase_service.dart';
import 'pages/admin_eo_request_page.dart';
import 'pages/event_list_management_page.dart';
import 'pages/event_history_page.dart';

// 2. Buat "Remote Control" navigasi agar bisa pindah halaman tanpa context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FCMService().initNotifications();

  // 3. Pindahkan listener ke sini (Sebelum runApp)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print("🔔 Notif diklik (Background)! Membawa data: ${message.data}");
    _handleNotificationClick(message.data);
  });

  runApp(const UniventApp());

  // 4. Tangkap pesan jika app dibuka dari keadaan mati total (Terminated)
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      print(
        "🚀 Aplikasi dibuka dari notif (Terminated)! Data: ${message.data}",
      );

      // Beri sedikit waktu agar UI (MaterialApp) selesai di-build dulu
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationClick(message.data);
      });
    }
  });
}

// Fungsi bantuan agar kodenya lebih rapi (tidak diulang 2 kali)
void _handleNotificationClick(Map<String, dynamic> data) {
  // 1. JALUR UNTUK ADMIN (Ada event baru diajukan)
  if (data['tipe'] == 'pengajuan_event') {
    print("Mengarahkan ADMIN ke halaman list event");
    navigatorKey.currentState?.pushNamed('/list-event');
  }
  // 2. JALUR UNTUK ADMIN (Ada user mau upgrade EO)
  else if (data['tipe'] == 'pengajuan_eo') {
    print("Mengarahkan ADMIN ke halaman list EO");
    navigatorKey.currentState?.pushNamed('/list-eo');
  }
  // 3. JALUR UNTUK EO (Event miliknya disetujui / ditolak)
  else if (data['tipe'] == 'status_event') {
    print("Mengarahkan EO ke halaman detail/history event");

    // 👇 Arahkan ke halaman riwayat event atau detail event milik EO
    // Ganti '/history-event' dengan rute halaman yang kamu punya untuk EO
    navigatorKey.currentState?.pushNamed('/history-event');
  } else if (data['tipe'] == 'eo_approved') {
    print("Aplikasi dibuka. User sukses jadi EO!");
  }
}

class UniventApp extends StatelessWidget {
  const UniventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 👈 5. Pasang Remote Control-nya di sini!
      title: 'Univent',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFE2B6E),
          primary: const Color(0xFFFE2B6E),
          secondary: const Color(0xFF232A3B),
        ),
        useMaterial3: true,
        fontFamily: 'Poppins',
      ),
      home: const UniventHomePage(),

      // Nantinya, daftarkan rute halamanmu di sini agar pushNamed bisa bekerja:
      routes: {
        '/list-event': (context) => const EventListManagementPage(),
        '/list-eo': (context) => const AdminEoRequestPage(),
        '/history-event': (context) => const EventHistoryPage(),
      },
    );
  }
}
