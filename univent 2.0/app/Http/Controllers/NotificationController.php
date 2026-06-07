<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Menandai notifikasi sebagai dibaca lalu mengarahkan ke halaman tujuan.
     */
    public function markAsReadAndRedirect($id)
    {
        // 1. Cari notifikasi berdasarkan ID milik user yang sedang login
        $notification = auth()->user()->notifications()->findOrFail($id);

        // 2. Tandai sebagai sudah dibaca
        $notification->markAsRead();

        // 3. LOGIKA BARU: Cek apakah ini notifikasi "Pengajuan EO Baru" (Untuk Admin)
        // 👉 PERBAIKAN: Kode if ini sudah disederhanakan agar tidak error "Undefined array key"
        if (isset($notification->data['type']) && $notification->data['type'] === 'eo_request') {
            return redirect('/admin/eo-requests');
        }

        // 4. Logika untuk Notifikasi Event yang DISETUJUI (Untuk EO)
        if (isset($notification->data['status']) && $notification->data['status'] === 'approved') {
            if (isset($notification->data['event_id'])) {
                // Arahkan EO ke halaman detail event
                return redirect()->route('events.show', $notification->data['event_id']);
            }
        }

        // 5. JALUR CADANGAN AMAN (Fallback)
        // Jika yang login adalah Admin (misal untuk notif event baru), arahkan ke Event List
        if (auth()->check() && auth()->user()->hasRole('admin')) {
            return redirect('/admin/event-list');
        }

        // Jika user biasa / EO, kembalikan ke Beranda
        return redirect()->route('dashboard');
    }
}