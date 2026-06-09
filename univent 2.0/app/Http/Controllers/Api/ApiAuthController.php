<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Role;
use App\Services\OtpService;
use App\Services\FcmService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Intervention\Image\Facades\Image;
use Illuminate\Support\Facades\Storage;
class ApiAuthController extends Controller
{
    protected OtpService $otpService;

    public function __construct(OtpService $otpService)
    {
        $this->otpService = $otpService;
    }

    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $parts = explode('@', $request->email);
        $name = $parts[0] ?: 'User';

        $user = User::create([
            'name' => $name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'is_active' => false,
        ]);

        $roleUser = Role::where('name', 'user')->first();
        if ($roleUser) {
            $user->roles()->attach($roleUser->id);
        }
        $user->profile()->create();

        // Generate dan kirim OTP via email
        $this->otpService->generateAndSend($user);

        return response()->json([
            'success' => true,
            'message' => 'Registrasi sukses. Kode OTP telah dikirim ke email Anda.',
            'email' => $user->email
        ], 201);
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
        ]);

        $user = User::where('email', $request->email)->first();

        // Cek email dan password
        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json(['success' => false, 'message' => 'Email atau password salah.'], 401);
        }

        // Cek apakah user sudah verifikasi OTP (saat registrasi)
        if (!$user->is_active) {
            return response()->json(['success' => false, 'message' => 'Akun belum diverifikasi. Silakan daftar ulang atau cek email Anda.'], 403);
        }

        // 👇 HAPUS LOGIKA OTP DI SINI, LANGSUNG BUATKAN TOKEN 👇
        $token = $user->createToken('univent_mobile_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil.',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role_name,
            ]
        ], 200);
    }

    public function verifyOtp(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|digits:6',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        if (!$this->otpService->verify($user, $request->otp)) {
            return response()->json(['success' => false, 'message' => 'OTP tidak valid atau sudah kadaluarsa.'], 400);
        }

        $this->otpService->reset($user);

        $user->email_verified_at = now();
        $user->is_active = true;
        $user->save();

        // Pembuatan token bearer Sanctum untuk Flutter
        $token = $user->createToken('univent_mobile_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Verifikasi berhasil.',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role_name,
            ]
        ], 200);
    }

    public function resendOtp(Request $request)
    {
        $request->validate(['email' => 'required|email']);
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);
        }

        try {
            $this->otpService->resendOtp($user);
            return response()->json(['success' => true, 'message' => 'Kode OTP baru telah dikirim.']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 429);
        }
    }
    
    // --- 1. Fungsi Mengirim OTP Lupa Password ---
    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email'
        ]);

        $otp = rand(100000, 999999);

        \Illuminate\Support\Facades\DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $request->email],
            ['token' => $otp, 'created_at' => now()]
        );

        // 👇 MENGIRIM EMAIL BENERAN KE GMAIL USER 👇
        try {
            // Desain email HTML persis seperti email registrasi
            $htmlContent = "
                <h2>Kode OTP Anda</h2>
                <p>Halo,</p>
                <p>Kode OTP Anda untuk reset password Univent adalah:</p>
                <h2><b>{$otp}</b></h2>
                <p>Jangan bagikan kode ini kepada siapapun. Berlaku selama 5 menit.</p>
            ";

            \Illuminate\Support\Facades\Mail::html($htmlContent, function ($message) use ($request) {
                $message->to($request->email)
                        ->subject('Kode OTP Reset Password');
            });
        } catch (\Exception $e) {
            return response()->json([
                'success' => false, 
                'message' => 'Gagal mengirim email: ' . $e->getMessage()
            ], 500);
        }

        return response()->json([
            'success' => true, 
            'message' => 'OTP untuk reset password telah berhasil dikirim ke email Anda!'
        ]);
    }

    // --- 2. Fungsi Reset Password dengan OTP ---
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email|exists:users,email',
            'otp' => 'required',
            'password' => 'required|min:8|confirmed' // Butuh parameter password_confirmation
        ]);

        // Cek apakah OTP valid
        $resetRecord = \Illuminate\Support\Facades\DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (!$resetRecord || $resetRecord->token !== $request->otp) {
            return response()->json(['success' => false, 'message' => 'Kode OTP tidak valid atau salah.'], 400);
        }

        // Jika OTP Benar, Ganti Password
        $user = \App\Models\User::where('email', $request->email)->first();
        $user->password = \Illuminate\Support\Facades\Hash::make($request->password);
        $user->save();

        // Hapus jejak OTP setelah berhasil digunakan
        \Illuminate\Support\Facades\DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        return response()->json(['success' => true, 'message' => 'Password berhasil diperbarui! Silakan login kembali.']);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['success' => true, 'message' => 'Berhasil logout.']);
    }
    public function getUserProfile(Request $request)
    {
        try {
\Illuminate\Support\Facades\Log::info("User Avatar Path: " . $user->avatar);            
            // Tarik data profil tambahan (untuk no HP & tanggal lahir)
            $profile = \App\Models\Profile::where('user_id', $user->id)->first();

            $userData = $user->toArray();
            
            // Sisipkan data dari tabel profiles (hanya phone & birthday)
            $userData['phone'] = $profile ? $profile->phone : null;
            $userData['birthday'] = ($profile && $profile->birthday) ? date('Y-m-d', strtotime($profile->birthday)) : null;
            
            // 👇 FIX UTAMA: Ambil avatar langsung dari tabel USERS 👇
            $userData['avatar'] = $user->avatar;

            $userData['role'] = $user->role_name ?? 'USER';
            
            return response()->json([
                'success' => true,
                'user' => $userData
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil profil: ' . $e->getMessage()
            ], 500);
        }
    }

    public function updateProfile(Request $request)
    {
        try {
            $user = $request->user();

            $request->validate([
                'name' => 'required|string|max:255',
                'phone' => 'nullable|string|max:20',
                'birthday' => 'nullable|date',
                'avatar' => 'nullable|image|mimes:jpeg,png,jpg|max:4096',
            ]);

            // 1. Update data dasar di tabel users
            $user->name = $request->name;

            // 👇 FIX UTAMA: Simpan file fisik avatar langsung ke tabel USERS 👇
            if ($request->hasFile('avatar')) {
            // Hapus yang lama
            if ($user->avatar && strlen($user->avatar) < 200) {
                \Illuminate\Support\Facades\Storage::disk('public')->delete($user->avatar);
            }
            
            // Kompres & Simpan
            $file = $request->file('avatar');
            $image = \Intervention\Image\Facades\Image::make($file)->resize(300, 300, function ($constraint) {
                $constraint->aspectRatio();
                $constraint->upsize();
            })->encode('jpg', 75);

            $filename = 'avatars/' . uniqid() . '.jpg';
            \Illuminate\Support\Facades\Storage::disk('public')->put($filename, $image);
            
            $user->avatar = $filename;
        }

            $user->save(); // Simpan nama dan avatar ke tabel users

            // 2. Update data detail (Phone & Birthday) ke tabel profiles
            $profile = \App\Models\Profile::firstOrCreate(['user_id' => $user->id]);

            $profile->phone = $request->filled('phone') ? $request->phone : null;
            $profile->birthday = $request->filled('birthday') ? $request->birthday : null;

            // (Hapus baris yang sebelumnya menyimpan avatar ke $profile)

            $profile->save();

            return response()->json([
                'success' => true, 
                'message' => 'Profil berhasil diperbarui!'
            ], 200);

        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error("Update Profile Error: " . $e->getMessage());
            
            return response()->json([
                'success' => false, 
                'message' => 'Gagal update: ' . $e->getMessage()
            ], 500);
        }
    }
    // --- FUNGSI UNTUK USER MENGAJUKAN DIRI JADI EO ---
    public function submitEoRequest(Request $request)
    {
        try {
            $user = $request->user();

            // Cek apakah user sudah pernah mengajukan dan masih pending
            if ($user->eo_request_status === 'pending') {
                return response()->json(['success' => false, 'message' => 'Anda sudah memiliki pengajuan yang sedang diproses.'], 400);
            }

            // Validasi data form
            $request->validate([
                'eo_org_type' => 'required|string',
                'eo_org_name' => 'required|string',
                'eo_pic_name' => 'required|string',
                'eo_phone' => 'required|string',
                'eo_instagram' => 'nullable|string'
            ]);

            // Update data user
            $user->eo_request_status = 'pending';
            $user->eo_org_type = $request->eo_org_type;
            $user->eo_org_name = $request->eo_org_name;
            $user->eo_pic_name = $request->eo_pic_name;
            $user->eo_phone = $request->eo_phone;
            $user->eo_instagram = $request->eo_instagram;
            $user->save();
            // Cari semua admin
$adminIds = \App\Models\AccountRole::where('role_id', 1)->pluck('user_id');
$admins = \App\Models\User::whereIn('id', $adminIds)->get();

if ($admins->count() > 0) {
    // Kirim notifikasi ke Admin bahwa ada pengajuan EO baru
    \Illuminate\Support\Facades\Notification::send($admins, new \App\Notifications\NewEoRequestNotification(auth()->user()));
    foreach ($admins as $admin) {
                FcmService::sendNotification(
                    $admin->fcm_token, 
                    'Pengajuan EO Baru 📢', 
                    auth()->user()->name . ' mengajukan diri sebagai EO.',
                    [
                        'tipe' => 'pengajuan_eo' // 👈 PASTIKAN TIKET INI ADA
    ]
                );
            }
}

            return response()->json([
                'success' => true,
                'message' => 'Pengajuan Upgrade EO berhasil dikirim! Silakan tunggu persetujuan Admin.'
            ], 200);


        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengirim pengajuan: ' . $e->getMessage()
            ], 500);
        }
    }
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        // Ambil user yang sedang login
        $user = $request->user(); 
        
        // Simpan tokennya
        $user->fcm_token = $request->fcm_token;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'FCM Token berhasil disimpan.'
        ]);
    }
    public function loginGoogle(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'name' => 'required|string'
        ]);

        // Cek apakah email sudah ada di database
        $user = User::where('email', $request->email)->first();

        // Jika user belum ada, daftarkan secara otomatis
        if (!$user) {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => \Illuminate\Support\Facades\Hash::make(\Illuminate\Support\Str::random(24)), // Password acak
                'is_active' => true, // Langsung aktif karena Google sudah terpercaya
                'email_verified_at' => now(),
            ]);

            // Berikan role 'user' secara default
            $roleUser = Role::where('name', 'user')->first();
            if ($roleUser) {
                $user->roles()->attach($roleUser->id);
            }
            
            // Buatkan profil kosong
            $user->profile()->create();
        }

        // Buatkan token Sanctum
        $token = $user->createToken('univent_mobile_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login Google berhasil.',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role_name ?? 'USER',
            ]
        ], 200);
    }
    
}