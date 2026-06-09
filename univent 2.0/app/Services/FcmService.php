<?php

namespace App\Services;

use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Messaging\AndroidConfig;

class FcmService
{
    /**
     * Fungsi utama untuk mengirim Notifikasi FCM
     * * @param string $fcmToken (Token HP tujuan)
     * @param string $title (Judul Notifikasi)
     * @param string $body (Isi Pesan)
     */
public static function sendNotification($fcmToken, $title, $body, $data = [])    {
        // Jika user tidak punya token (belum pernah login di HP), batalkan.
        if (empty($fcmToken)) {
            return false;
        }

        try {
            // Memanggil layanan kurir Firebase yang sudah kita install
            $messaging = app('firebase.messaging');

            // Membuat bungkus notifikasi
            $notification = Notification::create($title, $body);

            $androidConfig = AndroidConfig::fromArray([
                'priority' => 'high',
                'notification' => [
                    'sound' => 'default',
                ],
            ]);
            

            // Menentukan target token HP-nya
            // Masukkan setelan Android-nya ke dalam paketan pesan
            $message = CloudMessage::withTarget('token', $fcmToken)
                ->withNotification($notification)
                ->withAndroidConfig($androidConfig)
                ->withData($data);

            // Tembak!
            $messaging->send($message);

            return true;
            
        } catch (\Exception $e) {
            if (str_contains($e->getMessage(), 'Requested entity was not found')) {
                
                // Otomatis set null di database untuk user yang punya token rusak ini
                \App\Models\User::where('fcm_token', $fcmToken)->update(['fcm_token' => null]);
                
                // Catat ke log storage/logs/laravel.log untuk history pembersihan
                Log::warning("FCM CLEANUP: Token ghaib/mati terdeteksi dan telah dihapus otomatis dari database.");
                
                // Kembalikan false secara anggun agar proses submit/update event di web TIDAK IKUT CRASH!
                return false;
            }
    // 👇 Ganti dengan dd() agar error-nya tampil di layar!
    dd("GAGAL KIRIM NOTIF BOS! Ini alasannya: " . $e->getMessage());
}
    }
}