<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventOrganizer;
use App\Models\User;
use Illuminate\Http\Request;
use Carbon\Carbon;

class ApiEventController extends Controller
{
    public function getHomeData(Request $request)
    {
        // 1. Ambil data statistik untuk counter box di atas
        $totalEvents = Event::where('status', 'approved')->count();
        $totalOrganizers = EventOrganizer::count();
        $totalUsers = User::where('is_active', true)->count();

        // 2. Ambil 3 event terbaru sebagai rekomendasi khusus (FYP)
        $recommendedEvents = Event::with(['eventOrganizer', 'category'])
            ->where('status', 'approved')
            ->latest()
            ->take(3)
            ->get()
            ->map(function ($event) {
                return $this->formatEvent($event);
            });

        // 3. Ambil semua event approved lainnya untuk daftar utama
        $allEvents = Event::with(['eventOrganizer', 'category'])
            ->where('status', 'approved')
            ->latest()
            ->get()
            ->map(function ($event) {
                return $this->formatEvent($event);
            });

        return response()->json([
            'success' => true,
            'stats' => [
                'total_events' => (string) $totalEvents,
                'total_organizers' => (string) $totalOrganizers,
                'total_users' => (string) $totalUsers,
            ],
            'recommended' => $recommendedEvents,
            'all_events' => $allEvents,
        ], 200);
    }

    private function formatEvent($event)
    {
        return [
            'id' => $event->id,
            'title' => $event->event_title,
            'organizer' => $event->organizer_name ?? ($event->eventOrganizer->name ?? 'UKM / Himpunan'),
            'date' => \Carbon\Carbon::parse($event->start_date)->format('D, M d, Y'),
            'location' => $event->event_location,
            'category' => $event->category->name ?? 'Umum',
            'poster' => $event->event_poster, 
        ];
    }
    public function getAdminEvents(Request $request)
    {
        try {
            $user = $request->user();
            
            if (!$user) {
                return response()->json(['success' => false, 'message' => 'Unauthorized.'], 401);
            }

            // 👇 SOLUSI NYATA KODE 403 👇
            // Kita cek langsung ke model AccountRole sesuai Seeder-mu (role_id 1 = admin)
            $isAdminApi = \App\Models\AccountRole::where('user_id', $user->id)
                ->where('role_id', 1)
                ->exists();

            if (!$isAdminApi) {
                return response()->json([
                    'success' => false, 
                    'message' => 'Akses Ditolak. Akun Anda tidak memiliki hak akses Admin di API.'
                ], 403);
            }

            // Jika lolos, ambil data event
            $events = \App\Models\Event::with('eventOrganizer')
                ->latest()
                ->get()
                ->map(function ($event) {
                    return [
                        'id' => $event->id,
                        'title' => $event->event_title ?? 'Tanpa Judul',
                        'organizer' => $event->organizer_name ?? ($event->eventOrganizer->name ?? 'UKM/Himpunan'),
                        'status' => $event->status ?? 'pending',
                    ];
                });

            return response()->json([
                'success' => true,
                'data' => $events
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'ERROR API: ' . $e->getMessage()
            ], 500);
        }
    }
    public function getEventHistory(Request $request)
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json(['success' => false, 'message' => 'Unauthorized.'], 401);
            }

            \Carbon\Carbon::setLocale('id');

            // 👇 KITA HAPUS PENGECEKAN ADMIN DI SINI 👇
            // Semua role (Admin/EO/User) diperlakukan sama untuk urusan riwayat pribadi
            
            $eo = \App\Models\EventOrganizer::where('user_id', $user->id)->first();
            
            if ($eo) {
                // Jika user ini punya profil EO, HANYA tampilkan event buatannya sendiri
                $events = \App\Models\Event::with('eventOrganizer')
                    ->where('event_organizer_id', $eo->id)
                    ->latest()
                    ->get();
            } else {
                // Jika user biasa (atau Admin yang tidak pernah bikin event), kosongkan
                $events = collect();
            }

            // 3. Format data agar rapi
            $data = $events->map(function ($event) {
                $organizerName = 'UKM/Himpunan';
                if (!empty($event->organizer_name)) {
                    $organizerName = $event->organizer_name;
                } elseif ($event->relationLoaded('eventOrganizer') && $event->eventOrganizer) {
                    $organizerName = $event->eventOrganizer->name;
                }

                return [
                    'id' => $event->id,
                    'title' => $event->title ?? $event->event_title ?? 'Tanpa Judul', 
                    'date' => $event->start_date ? \Carbon\Carbon::parse($event->start_date)->translatedFormat('d F Y') : '-',
                    'status' => $event->status ?? 'pending',
                    'organizer' => $organizerName,
                ];
            });

            return response()->json([
                'success' => true,
                'data' => $data
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'ERROR API HISTORY: ' . $e->getMessage()
            ], 500);
        }
    }
    public function submitEvent(Request $request)
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json(['success' => false, 'message' => 'Unauthorized.'], 401);
            }

            // Validasi input dasar
            $request->validate([
                'event_title' => 'required|string|max:255',
                'category_id' => 'required|integer',
                'start_date' => 'required|date',
                'event_description' => 'required|string',
            ]);

            // Tentukan status awal dan Organizer ID
            $status = 'pending'; // Default harus di-ACC Admin dulu
            $organizerId = null;
            $organizerType = 'UKM / Himpunan'; // Default
            $organizerName = $user->name;

            // Cek apakah user adalah Admin
            $isAdmin = \App\Models\AccountRole::where('user_id', $user->id)->where('role_id', 1)->exists();
            
            if ($isAdmin) {
                // Jika Admin yang buat, bisa langsung berstatus 'approved' 
                $status = 'approved';
                $organizerName = 'Admin Univent';

                // 👇 FIX: Buatkan/Cari data Organizer khusus untuk Admin 👇
                $eo = \App\Models\EventOrganizer::where('user_id', $user->id)->first();
                if (!$eo) {
                    $eo = \App\Models\EventOrganizer::create([
                        'user_id' => $user->id,
                        'name' => 'Admin Univent',
                        'contact_email' => $user->email,
                    ]);
                }
                $organizerId = $eo->id;

            } else {
                // Cek data EO untuk user biasa
                $eo = \App\Models\EventOrganizer::where('user_id', $user->id)->first();
                
                // JIKA DATA EO BELUM ADA, KITA BUATKAN OTOMATIS
                if (!$eo) {
                    // Pastikan dia memang punya role EO (role_id 2)
                    $isRoleEo = \App\Models\AccountRole::where('user_id', $user->id)->where('role_id', 2)->exists();
                    
                    if ($isRoleEo) {
                        $eo = \App\Models\EventOrganizer::create([
                            'user_id' => $user->id,
                            'name' => 'Organizer ' . $user->name, // Nama default
                            'contact_email' => $user->email,
                        ]);
                    } else {
                        return response()->json(['success' => false, 'message' => 'Akun Anda tidak terdaftar sebagai EO.'], 403);
                    }
                }
                
                $organizerId = $eo->id;
                $organizerName = $eo->name;
            }

            $posterPath = 'default_poster.png'; // Nilai default jika user tidak upload
            if ($request->hasFile('event_poster')) {
                // Simpan ke folder public/storage/posters
                $posterPath = $request->file('event_poster')->store('posters', 'public');
            }
            // Simpan ke database
            $event = \App\Models\Event::create([
                'event_organizer_id' => $organizerId,
                'organizer_type' => $organizerType,
                'organizer_name' => $organizerName,
                'category_id' => $request->category_id,
                'event_title' => $request->event_title,
                'event_description' => $request->event_description,
                'start_date' => $request->start_date,
                'start_time' => $request->start_time ?? '00:00:00',
                'end_date' => $request->end_date,
                'end_time' => $request->end_time,
                'event_location' => $request->event_location ?? 'Belum ditentukan',
                'registration_link' => $request->registration_link,
                'contact_person' => $request->contact_person,
                'status' => $status,
                // Untuk gambar poster, kita hardcode dulu sementara jika tidak ada upload
                'event_poster' => $posterPath, 
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Event berhasil diajukan!',
                'data' => $event
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal submit: ' . $e->getMessage()
            ], 500);
        }
    }
    public function getEventDetail($id)
    {
        try {
            // Cari event berdasarkan ID beserta data penyelenggaranya
            $event = \App\Models\Event::with('eventOrganizer')->find($id);

            if (!$event) {
                return response()->json([
                    'success' => false, 
                    'message' => 'Data event tidak ditemukan di database.'
                ], 404);
            }

            // Kita format datanya biar Flutter tinggal terima beres (termasuk format tanggal)
            $data = [
                'id' => $event->id,
                'status' => $event->status ?? 'pending',
                'event_title' => $event->event_title ?? 'Tanpa Judul',
                'event_poster' => $event->event_poster,
                // Kalau ada tabel relasi category_name bisa disesuaikan, sementara kita fallback aman:
                'category_name' => 'Event Category', 
                'organizer_type' => strtoupper($event->organizer_type ?? 'ORGANIZATION'),
                'organizer_name' => $event->organizer_name ?? ($event->eventOrganizer->name ?? 'Admin Univent'),
                
                // Format Tanggal (Contoh: 03 Apr 2026)
                'start_date' => $event->start_date ? \Carbon\Carbon::parse($event->start_date)->translatedFormat('d M Y') : '-',
                'end_date' => $event->end_date ? \Carbon\Carbon::parse($event->end_date)->translatedFormat('d M Y') : '-',
                
                // Format Jam (Contoh: 08:00 AM)
                'start_time' => $event->start_time ? \Carbon\Carbon::parse($event->start_time)->format('h:i A') : '-',
                'end_time' => $event->end_time ? \Carbon\Carbon::parse($event->end_time)->format('h:i A') : '-',
                
                'event_location' => $event->event_location ?? 'Belum ditentukan',
                'registration_link' => $event->registration_link ?? '-',
                'contact_person' => $event->contact_person ?? '-',
                'event_description' => $event->event_description ?? '-',
                
            ];

            return response()->json([
                'success' => true,
                'data' => $data
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'ERROR API DETAIL: ' . $e->getMessage()
            ], 500);
        }
    }
    public function updateEvent(Request $request, $id) {
    try {
        $event = \App\Models\Event::findOrFail($id);
        
        // Proteksi: Hanya pemilik event atau admin yang boleh edit
        $user = $request->user();
        $isAdmin = \App\Models\AccountRole::where('user_id', $user->id)->where('role_id', 1)->exists();
        $eo = \App\Models\EventOrganizer::where('user_id', $user->id)->first();

        if (!$isAdmin && ($eo && $event->event_organizer_id !== $eo->id)) {
             return response()->json(['success' => false, 'message' => 'Anda tidak berhak mengedit event ini.'], 403);
        }

        $event->update($request->all());

        return response()->json([
            'success' => true,
            'message' => 'Event berhasil diperbarui!',
            'data' => $event
        ]);
    } catch (\Exception $e) {
        return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
    }
}
// Fungsi untuk merubah status (ACC / Reject)
    public function updateStatus(Request $request, $id)
    {
        try {
            $user = $request->user();
            // Proteksi: Wajib Admin
            $isAdmin = \App\Models\AccountRole::where('user_id', $user->id)->where('role_id', 1)->exists();
            if (!$isAdmin) {
                return response()->json(['success' => false, 'message' => 'Unauthorized. Khusus Admin.'], 403);
            }

            $request->validate([
                'status' => 'required|in:approved,rejected,pending'
            ]);

            $event = \App\Models\Event::findOrFail($id);
            $event->status = $request->status;
            $event->save();

            return response()->json(['success' => true, 'message' => 'Status event berhasil diperbarui!']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

    // Fungsi untuk menghapus event permanen
    public function deleteEvent(Request $request, $id)
    {
        try {
            $user = $request->user();
            // Proteksi: Wajib Admin
            $isAdmin = \App\Models\AccountRole::where('user_id', $user->id)->where('role_id', 1)->exists();
            if (!$isAdmin) {
                return response()->json(['success' => false, 'message' => 'Unauthorized. Khusus Admin.'], 403);
            }

            $event = \App\Models\Event::findOrFail($id);
            $event->delete();

            return response()->json(['success' => true, 'message' => 'Event berhasil dihapus permanen!']);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}