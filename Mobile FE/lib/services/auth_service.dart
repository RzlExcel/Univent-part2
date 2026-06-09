import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';

// ⚠️ Pastikan nama file ini sesuai dengan file Firebase-mu
import 'firebase_service.dart';

class ApiAuthService {
  // ==================================================================
  // 🌐 PENGATURAN BASE URL API
  // ==================================================================
  static const String baseUrl = "http://10.0.2.2:8000/api";
  static String? token;

  // ==================================================================
  // 🚀 FUNGSI BANTUAN FCM
  // ==================================================================
  // Dijadikan static agar bisa dipakai oleh Login Biasa & Login Google
  static Future<void> sendFcmTokenToServer(String bearerToken) async {
    try {
      // ⚠️ CEK DI SINI: Pastikan nama class-nya benar FCMService atau sesuaikan dengan milikmu
      String? fcmToken = await FCMService().getFcmToken();

      if (fcmToken != null) {
        final response = await http.post(
          Uri.parse('$baseUrl/update-fcm-token'), // Menggunakan baseUrl
          headers: {
            'Authorization': 'Bearer $bearerToken',
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

  // ==================================================================
  // 🔑 AUTENTIKASI UTAMA
  // ==================================================================

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

  // --- 2. HTTP REQUEST LOGIN BIASA ---
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

      if (response.statusCode == 200 && data['token'] != null) {
        String tokenSanctum = data['token'];

        // Simpan token ke memori
        ApiAuthService.token = tokenSanctum;

        // Panggil fungsi kirim FCM token
        await ApiAuthService.sendFcmTokenToServer(tokenSanctum);
      }

      return data;
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // --- 3. HTTP REQUEST LOGIN GOOGLE ---
  static bool _isGoogleInitialized = false;

  static Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // 1. ATURAN BARU V7: Wajib initialize satu kali sebelum dipakai
      if (!_isGoogleInitialized) {
        await GoogleSignIn.instance.initialize();
        _isGoogleInitialized = true;
      }

      // 2. ATURAN BARU V7: Panggil instance.authenticate() (Bukan .signIn() lagi)
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance
          .authenticate();

      // Kalau user batal/close pop-up
      if (googleUser == null) {
        return {'success': false, 'message': 'Dibatalkan oleh user'};
      }

      // 3. Kirim data Email & Nama ke API Laravel (Sama seperti sebelumnya)
      final response = await http.post(
        Uri.parse('$baseUrl/login-google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': googleUser.email,
          'name': googleUser.displayName ?? 'User Univent',
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Simpan Token Sanctum
        token = responseData['token'];

        // Kirim FCM Token ke server agar user login Google tetap dapat notifikasi!
        await sendFcmTokenToServer(token!);

        return {'success': true, 'message': 'Login Google berhasil'};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Gagal login ke server.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ==================================================================
  // 🛡️ FITUR KEAMANAN & OTP
  // ==================================================================

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
          "password_confirmation": confirmPassword,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"success": false, "message": "Gagal terhubung ke server: $e"};
    }
  }

  // ==================================================================
  // 👤 FITUR PROFIL & EO
  // ==================================================================

  static Future<Map<String, dynamic>> getUserProfile() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      '$baseUrl/user-profile?t=$timestamp',
    ); // Menggunakan baseUrl
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

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, String> data, {
    File? avatarFile,
  }) async {
    final url = Uri.parse("$baseUrl/profile/update");
    try {
      var request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      });
      request.fields.addAll(data);

      if (avatarFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('avatar', avatarFile.path),
        );
      }

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
}
