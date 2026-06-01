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
            // Jika gagal, catat error-nya secara diam-diam di log laravel
            Log::error("Gagal kirim FCM: " . $e->getMessage());
            return false;
        }
    }
}