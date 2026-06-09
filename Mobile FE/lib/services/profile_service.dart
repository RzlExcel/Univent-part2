import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Untuk mengambil baseUrl dan token statis

class ApiProfileService {
  static const String baseUrl = ApiAuthService.baseUrl;

  Future<Map<String, dynamic>> fetchProfile() async {
    final url = Uri.parse("$baseUrl/user-profile");

    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          // 👇 KIRIM KUNCI PAS TOKEN DI SINI 👇
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Gagal memuat data profil (Sesi Habis).",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Eror koneksi profil: $e"};
    }
  }
}
