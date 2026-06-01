import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'firebase_service.dart';

class ApiAuthService {
  // ==================================================================
  // 🌐 PENGATURAN BASE URL API
  // ==================================================================

  // 1. Versi Emulator Android (AKTIF)
  // 10.0.2.2 adalah alias standar emulator untuk localhost komputer
  static const String baseUrl = "http://10.0.2.2:8000/api";

  // 2. Versi HP Fisik / Real Device (DINONAKTIFKAN)
  // Ganti "192.168.1.X" dengan IPv4 komputermu (cek lewat CMD: ipconfig)
  // Pastikan HP dan Laptop terhubung ke jaringan WiFi yang sama!
  // static const String baseUrl = "http://192.168.1.X:8000/api";

  // ==================================================================
  static String? token;
  // --- 1. HTTP REQUEST REGISTRASI ---
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse("$baseUrl/register");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // --- 2. HTTP REQUEST LOGIN ---
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/login");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "password": password}),
      );
      var data = jsonDecode(response.body);

      // Cek apakah login sukses (biasanya status 200) dan token tersedia
      if (response.statusCode == 200 && data['token'] != null) {
        // Ambil token sanctum/bearer dari respons Laravel
        String tokenSanctum = data['token'];

        // Panggil fungsi kirim FCM token ke database Univent
        await sendFcmTokenToServer(tokenSanctum);
      }

      // Kembalikan data aslinya ke halaman Login (login_page.dart)
      return data;
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // --- 3. HTTP REQUEST VERIFIKASI OTP ---
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final url = Uri.parse("$baseUrl/verify-otp");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email, "otp": otp}),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal verifikasi: $e"};
    }
  }

  // --- 4. HTTP REQUEST RESEND OTP ---
  Future<Map<String, dynamic>> resendOtp(String email) async {
    final url = Uri.parse("$baseUrl/resend-otp");
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"email": email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // Fungsi 1: Minta OTP Lupa Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse("$baseUrl/forgot-password");
    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"email": email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // Fungsi 2: Proses Reset Password
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String password,
    String confirmPassword,
  ) async {
    final url = Uri.parse("$baseUrl/reset-password");
    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "password": password,
          "password_confirmation":
              confirmPassword, // Wajib untuk lolos validasi Laravel
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // Mengambil data profil saat ini
  static Future<Map<String, dynamic>> getUserProfile() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('http://10.0.2.2:8000/api/user-profile?t=$timestamp');
    try {
      final response = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {"success": false, "message": "Gagal memuat profil"};
    } catch (e) {
      return {"success": false, "message": "Eror: $e"};
    }
  }

  // Mengirim data update profil (Seperti yang kita buat sebelumnya)
  // Update profil dengan dukungan Upload Foto
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, String> data, {
    File? avatarFile,
  }) async {
    final url = Uri.parse("$baseUrl/profile/update");
    try {
      var request = http.MultipartRequest('POST', url);

      // Masukkan header token
      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });

      // Masukkan data teks
      request.fields.addAll(data);

      // Jika ada gambar yang dipilih, masukkan ke request
      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatarFile.path),
        );
      }

      // Kirim request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {
        "success": false,
        "message": "Gagal memperbarui profil (Status: ${response.statusCode})",
      };
    } catch (e) {
      return {"success": false, "message": "Eror Koneksi: $e"};
    }
  }

  // Fungsi untuk Submit Pengajuan Upgrade EO
  static Future<Map<String, dynamic>> submitEoRequest(
    Map<String, String> data,
  ) async {
    final url = Uri.parse("$baseUrl/upgrade-eo");
    try {
      final response = await http.post(
        url,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        return {
          "success": false,
          "message": errorData['message'] ?? "Gagal mengirim pengajuan.",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Eror Koneksi: $e"};
    }
  }

  // FCM
  Future<void> sendFcmTokenToServer(String bearerToken) async {
    try {
      // 1. Ambil token FCM dari HP
      String? fcmToken = await FCMService().getFcmToken();

      if (fcmToken != null) {
        // 2. Kirim ke API Laravel yang baru kita buat
        final response = await http.post(
          Uri.parse(
            'http://10.0.2.2:8000/api/update-fcm-token',
          ), // Ganti dengan URL API-mu
          headers: {
            'Authorization':
                'Bearer $bearerToken', // Token Sanctum user yang sedang login
            'Accept': 'application/json',
          },
          body: {'fcm_token': fcmToken},
        );

        if (response.statusCode == 200) {
          print("Sukses menyimpan FCM Token di database!");
        } else {
          print("Gagal menyimpan FCM Token: ${response.body}");
        }
      }
    } catch (e) {
      print("Error kirim FCM Token: $e");
    }
  }
}
