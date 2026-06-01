<?php

use App\Http\Controllers\Api\ApiAuthController;
use App\Http\Controllers\Api\ApiEventController;
use Illuminate\Support\Facades\Route;

// Public API Routes
Route::post('/register', [ApiAuthController::class, 'register']);
Route::post('/login', [ApiAuthController::class, 'login']);
Route::post('/verify-otp', [ApiAuthController::class, 'verifyOtp']);
Route::post('/resend-otp', [ApiAuthController::class, 'resendOtp']);
// API untuk Forgot & Reset Password
Route::post('/forgot-password', [ApiAuthController::class, 'forgotPassword']);
Route::post('/reset-password', [ApiAuthController::class, 'resetPassword']);

// Protected API Routes (Contoh menggunakan middleware token expiry kamu)
Route::middleware(['auth:sanctum', \App\Http\Middleware\CheckTokenExpiry::class])->group(function () {
    Route::post('/logout', [ApiAuthController::class, 'logout']);
    
    // 👇 ENDPOINT UNTUK AMBIL DATA PROFIL UTUT 👇
    // ENDPOINT UNTUK AMBIL DATA PROFIL UTUT
    Route::get('/user-profile', function () {
        $user = auth()->user();
        
        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role_name ?? 'USER', 
                'phone' => $user->profile?->phone ?? 'Belum diatur',
                'birthday' => $user->profile?->birthday ? $user->profile->birthday->format('Y-m-d') : 'Belum diatur',
                'avatar' => $user->avatar,
            ]
        ], 200);
    });
    // API untuk Manajemen Event (Admin Only)
    Route::get('/event-list', [App\Http\Controllers\Api\ApiEventController::class, 'getAdminEvents']);
    // API untuk Ubah Status Event (Accept / Reject)
    Route::put('/event-status/{id}', [App\Http\Controllers\Api\ApiEventController::class, 'updateStatus']);
    // API untuk Hapus Event
    Route::delete('/event-delete/{id}', [App\Http\Controllers\Api\ApiEventController::class, 'deleteEvent']);
// API untuk Riwayat Event (Admin & EO)
    Route::get('/event-history', [App\Http\Controllers\Api\ApiEventController::class, 'getEventHistory']);
// API untuk Submit Event Baru
    Route::post('/event/submit', [App\Http\Controllers\Api\ApiEventController::class, 'submitEvent']);
// API untuk Ambil Detail 1 Event
    Route::get('/event-detail/{id}', [App\Http\Controllers\Api\ApiEventController::class, 'getEventDetail']);
Route::put('/event-update/{id}', [ApiEventController::class, 'updateEvent']);
// API untuk Update Profil
    Route::post('/profile/update', [App\Http\Controllers\Api\ApiAuthController::class, 'updateProfile']);
// API untuk Submit Pengajuan EO (Oleh User)
    Route::post('/upgrade-eo', [App\Http\Controllers\Api\ApiAuthController::class, 'submitEoRequest']);
// --- API KHUSUS ADMIN (Manajemen EO) ---
    Route::get('/admin/eo-requests', [App\Http\Controllers\Api\ApiAdminController::class, 'getPendingEoRequests']);
    Route::post('/admin/eo-requests/{id}/approve', [App\Http\Controllers\Api\ApiAdminController::class, 'approveEoRequest']);
    Route::post('/admin/eo-requests/{id}/reject', [App\Http\Controllers\Api\ApiAdminController::class, 'rejectEoRequest']);
// --- API CONTACT US 
Route::post('/contact-us', [App\Http\Controllers\Api\ApiContactController::class, 'store']);
// Notifikasi
Route::get('/notifications', [\App\Http\Controllers\Api\ApiNotificationController::class, 'index']);
Route::post('/notifications/read', [\App\Http\Controllers\Api\ApiNotificationController::class, 'markAsRead']);
Route::get('/notifications/unread-count', [\App\Http\Controllers\Api\ApiNotificationController::class, 'unreadCount']);
Route::post('/update-fcm-token', [ApiAuthController::class, 'updateFcmToken']);




    
    });


// Rute ambil data event untuk halaman Home & Guest
Route::get('/home-events', [ApiEventController::class, 'getHomeData']);
