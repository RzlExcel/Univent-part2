import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Kita pinjam baseUrl dan token dari sini

class ApiAdminService {
  // 1. Tarik Data Pending
  static Future<Map<String, dynamic>> getPendingRequests() async {
    final url = Uri.parse("${ApiAuthService.baseUrl}/admin/eo-requests");
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal mengambil data: $e"};
    }
  }

  // 2. Setujui EO
  static Future<Map<String, dynamic>> approveEo(int id) async {
    final url = Uri.parse(
      "${ApiAuthService.baseUrl}/admin/eo-requests/$id/approve",
    );
    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Error koneksi: $e"};
    }
  }

  // 3. Tolak EO
  static Future<Map<String, dynamic>> rejectEo(int id) async {
    final url = Uri.parse(
      "${ApiAuthService.baseUrl}/admin/eo-requests/$id/reject",
    );
    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Error koneksi: $e"};
    }
  }
}
