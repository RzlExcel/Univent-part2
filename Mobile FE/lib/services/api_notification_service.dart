import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiNotificationService {
  static final Dio _dio = Dio();
  // Sesuaikan dengan IP laptopmu
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<Map<String, dynamic>> getNotifications() async {
    try {
      final token = ApiAuthService.token;
      if (token == null) return {'success': false, 'message': 'Belum login'};

      final response = await _dio.get(
        '$baseUrl/notifications',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': 'Gagal memuat notifikasi'};
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      final token = ApiAuthService.token;
      if (token == null) return;

      await _dio.post(
        '$baseUrl/notifications/read',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );
    } catch (e) {
      print("Gagal update status read");
    }
  }

  static Future<int> getUnreadCount() async {
    try {
      final token = ApiAuthService.token;
      if (token == null) return 0;

      final response = await _dio.get(
        '$baseUrl/notifications/unread-count',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.data['success'] == true) {
        return response.data['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  static Future<Map<String, dynamic>> clearAllNotifications() async {
    try {
      final token = ApiAuthService.token;
      if (token == null) return {'success': false, 'message': 'Belum login'};

      // Menembak route API DELETE Laravel yang sudah kita amankan kemarin
      final response = await _dio.delete(
        '$baseUrl/notifications/clear-all',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return response
          .data; // Mengembalikan data json response sukses dari Laravel bos
    } catch (e) {
      return {'success': false, 'message': 'Gagal membersihkan notifikasi: $e'};
    }
  }
}
