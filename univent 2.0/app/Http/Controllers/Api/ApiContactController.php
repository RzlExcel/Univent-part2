<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Contact;
use Illuminate\Support\Facades\Mail;       // 👈 Wajib import Facades Mail
use App\Mail\ContactNotification;          // 👈 Import Mailable buatanmu

class ApiContactController extends Controller
{
    public function store(Request $request)
    {
        try {
            $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email',
                'message' => 'required|string',
            ]);

            // 1. Simpan ke database
            $contact = Contact::create([
                'user_id' => auth('sanctum')->id(),
                'name' => $request->name,
                'email' => $request->email,
                'message' => $request->message,
            ]);

            // 2. Tembak email pakai Mailable ContactNotification buatanmu
            Mail::to('univenttelkom@gmail.com')->send(new ContactNotification($contact));

            return response()->json([
                'success' => true,
                'message' => 'Pesan Anda berhasil dikirim ke Admin Univent!'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengirim pesan: ' . $e->getMessage()
            ], 500);
        }
    }
}