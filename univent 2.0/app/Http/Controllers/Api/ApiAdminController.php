<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Services\FcmService;

class ApiAdminController extends Controller
{
    // 1. Ambil daftar user yang statusnya 'pending'
    public function getPendingEoRequests()
    {
        $requests = User::where('eo_request_status', 'pending')
                        ->orderBy('updated_at', 'asc')
                        ->get();

        return response()->json(['success' => true, 'data' => $requests], 200);
    }

    // 2. Fungsi untuk Setujui (Approve)
    public function approveEoRequest($id)
    {
        $user = User::find($id);
        if (!$user) return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);

        // HAPUS baris $user->role = 'EO'; dan ganti dengan ini:
        $user->syncRoles(['EO']); // atau $user->assignRole('EO');
        
        $user->eo_request_status = 'approved';
        $user->save();

        if (class_exists(\App\Notifications\EoRequestStatusNotification::class)) {
            $user->notify(new \App\Notifications\EoRequestStatusNotification('approved'));
        }
        FcmService::sendNotification(
            $user->fcm_token, 
            'Pengajuan EO Disetujui! 🎉', 
            'Selamat, pengajuan Upgrade EO kamu telah disetujui Admin.'
        );

        return response()->json(['success' => true, 'message' => 'Pengajuan disetujui! User sekarang adalah EO.']);
    }

    // 3. Fungsi untuk Tolak (Reject)
    public function rejectEoRequest($id)
    {
        $user = User::find($id);
        if (!$user) return response()->json(['success' => false, 'message' => 'User tidak ditemukan.'], 404);

        $user->eo_request_status = 'rejected';
        $user->save();

        if (class_exists(\App\Notifications\EoRequestStatusNotification::class)) {
            $user->notify(new \App\Notifications\EoRequestStatusNotification('rejected'));
        }

        FcmService::sendNotification(
            $user->fcm_token, 
            'Pengajuan EO Ditolak 😔', 
            'Mohon maaf, pengajuan Upgrade EO kamu ditolak oleh Admin.'
        );

        return response()->json(['success' => true, 'message' => 'Pengajuan ditolak.']);
    }
}