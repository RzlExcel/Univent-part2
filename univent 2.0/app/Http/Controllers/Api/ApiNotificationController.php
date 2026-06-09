<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class ApiNotificationController extends Controller
{
    // Mengambil daftar notifikasi
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Ambil 20 notifikasi terbaru
        $notifications = $user->notifications()->take(20)->get();

        
        // Format datanya agar gampang dibaca oleh Flutter
       $formatted = $notifications->map(function ($notif) {
            return [
                'id' => $notif->id,
                'type' => class_basename($notif->type),
                // Kita asumsikan isi 'data' punya 'title' dan 'message'
                'title' => $notif->data['title'] ?? 'Notifikasi Univent',
                'message' => $notif->data['message'] ?? 'Kamu punya pemberitahuan baru.',
                'is_read' => $notif->read_at !== null,
                'created_at' => $notif->created_at->diffForHumans(), // Contoh: "2 jam yang lalu"
            ];
        });

        return response()->json([
            'success' => true,
            'unread_count' => $user->unreadNotifications->count(),
            'data' => $formatted
        ], 200);
    }

    // Menandai semua notifikasi sudah dibaca
    public function markAsRead(Request $request)
    {
        $request->user()->unreadNotifications->markAsRead();

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi telah dibaca'
        ], 200);
    }
    public function unreadCount(Request $request)
    {
        return response()->json([
            'success' => true,
            'unread_count' => $request->user()->unreadNotifications->count()
        ], 200);
    }
    /**
     * Hapus semua notifikasi milik user yang sedang login via Mobile
     */
    public function clearAll(Request $request)
    {
        try {
            $user = auth()->user(); // Ambil user mobile yang sedang login

            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User tidak login.'
                ], 401);
            }

            // Pilihan A: Jika pakai Database Notification bawaan Laravel (Tabel notifications default)
            $user->notifications()->delete();

            // Pilihan B: JIKA bos pakai tabel buatan sendiri, aktifkan baris di bawah ini dan sesuaikan nama Modelnya:
            // \App\Models\Notification::where('user_id', $user->id)->delete();

            return response()->json([
                'success' => true,
                'message' => 'Semua notifikasi berhasil disapu bersih, bos!'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal di server Laravel: ' . $e->getMessage()
            ], 500);
        }
    }
}