import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Impor untuk menggunakan variabel baseUrl yang sama
import 'package:flutter/foundation.dart';

class ApiEventService {
  static const String baseUrl = ApiAuthService.baseUrl;

  // Mengambil bundle data komplit untuk halaman depan
  Future<Map<String, dynamic>> fetchHomeData() async {
    final url = Uri.parse("$baseUrl/home-events");
    try {
      final response = await http.get(
        url,
        headers: {"Accept": "application/json"},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Gagal memuat data dari server"};
      }
    } catch (e) {
      return {"success": false, "message": "Eror koneksi jaringan: $e"};
    }
  }

  // Tambahkan fungsi ini untuk mengambil data manajemen event khusus Admin
  Future<Map<String, dynamic>> fetchAdminEvents() async {
    final url = Uri.parse("$baseUrl/event-list");
    try {
      // 🚨 PRINT 1: Cek apakah token admin benar-benar dikirim atau malah kosong (null)
      debugPrint("====== [DEBUG API] START CALL ======");
      debugPrint("Token yang dikirim: ${ApiAuthService.token}");

      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );

      // 🚨 PRINT 2: Cek status code (Apakah 401 Unauthorized, 403 Forbidden, atau 500 Crash)
      debugPrint("Status Code dari Server: ${response.statusCode}");

      // 🚨 PRINT 3: Cek isi pesan asli dari Laravel (Apakah ada eror SQL atau PHP)
      debugPrint("Response Body dari Server: ${response.body}");
      debugPrint("====== [DEBUG API] END CALL ======");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        "success": false,
        "message": "Gagal memuat data admin (Status: ${response.statusCode})",
      };
    } catch (e) {
      debugPrint("🚨 CRASH DI FLUTTER: $e");
      return {"success": false, "message": "Eror Koneksi: $e"};
    }
  }

  // Mengambil data riwayat event (Event History)
  Future<Map<String, dynamic>> fetchEventHistory() async {
    final url = Uri.parse("$baseUrl/event-history");
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Gagal memuat riwayat event."};
    } catch (e) {
      return {"success": false, "message": "Eror: $e"};
    }
  }

  // Fungsi untuk Submit Event
  // Fungsi untuk Submit Event
  Future<Map<String, dynamic>> submitEvent(
    Map<String, String> eventData, { // <--- Ubah jadi String, String
    File? posterFile, // <--- Tambahkan parameter File
  }) async {
    final url = Uri.parse("$baseUrl/event/submit");
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer ${ApiAuthService.token}",
      });

      // 1. Masukkan semua data teks (Judul, Tgl, dll)
      request.fields.addAll(eventData);

      // 2. Masukkan file gambar JIKA ADA
      if (posterFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'event_poster', // <--- Sesuai dengan yang dicari Laravel
            posterFile.path,
          ),
        );
      }

      // 3. Kirim ke server
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            "success": false,
            "message": errorData['message'] ?? "Error ${response.statusCode}",
          };
        } catch (_) {
          return {
            "success": false,
            "message": "Crash Server: ${response.statusCode}",
          };
        }
      }
    } catch (e) {
      return {"success": false, "message": "Eror Koneksi: $e"};
    }
  }

  // Mengambil detail satu event berdasarkan ID
  Future<Map<String, dynamic>> fetchEventDetail(int eventId) async {
    final url = Uri.parse("$baseUrl/event-detail/$eventId");
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Gagal memuat detail event."};
    } catch (e) {
      return {"success": false, "message": "Eror Koneksi: $e"};
    }
  }

  // Fungsi untuk Update/Edit Event
  Future<Map<String, dynamic>> updateEvent(
    int eventId,
    Map<String, dynamic> eventData,
  ) async {
    final url = Uri.parse("$baseUrl/event-update/$eventId");
    try {
      final response = await http.put(
        // Menggunakan PUT untuk update
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
        body: jsonEncode(eventData),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      final errorData = jsonDecode(response.body);
      return {
        "success": false,
        "message": errorData['message'] ?? "Gagal update data.",
      };
    } catch (e) {
      return {"success": false, "message": "Eror: $e"};
    }
  }

  // Fungsi Update Status (Accept / Reject)
  Future<Map<String, dynamic>> updateEventStatus(
    int eventId,
    String status,
  ) async {
    final url = Uri.parse("$baseUrl/event-status/$eventId");
    try {
      final response = await http.put(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
        body: jsonEncode({"status": status}),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Gagal mengupdate status event."};
    } catch (e) {
      return {"success": false, "message": "Eror Koneksi: $e"};
    }
  }

  // Fungsi Hapus Event
  Future<Map<String, dynamic>> deleteEvent(int eventId) async {
    final url = Uri.parse("$baseUrl/event-delete/$eventId");
    try {
      final response = await http.delete(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Gagal menghapus event."};
    } catch (e) {
      return {"success": false, "message": "Eror Koneksi: $e"};
    }
  }
}
