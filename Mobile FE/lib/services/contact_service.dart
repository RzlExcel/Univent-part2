import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart'; // Kita pinjam baseUrl dari sini

class ApiContactService {
  // Fungsi untuk mengirim pesan Contact Us
  static Future<Map<String, dynamic>> sendMessage(
    String name,
    String email,
    String message,
  ) async {
    final url = Uri.parse("${ApiAuthService.baseUrl}/contact-us");

    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${ApiAuthService.token}",
        },
        body: jsonEncode({"name": name, "email": email, "message": message}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Gagal mengirim pesan. Silakan coba lagi.",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Error koneksi: $e"};
    }
  }
}
