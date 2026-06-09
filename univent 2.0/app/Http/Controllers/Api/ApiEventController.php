<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventOrganizer;
use App\Models\User;
use Illuminate\Http\Request;
use App\Services\FcmService;
use Carbon\Carbon;

class ApiEventController extends Controller
{
    public function getHomeData(Request $request)
    {
        $totalEvents = Event::where('status', 'approved')->count();
        $totalOrganizers = EventOrganizer::count();
        $totalUsers = User::where('is_active', true)->count();

        // MESIN REKOMENDASI (PERSONALIZATION)
        $userId = auth('sanctum')->id(); 
        $ipAddress = $request->ip();
        $userAgent = $request->userAgent();

        $clickQuery = \DB::table('user_event_clicks')
            ->join('events', 'user_event_clicks.event_id', '=', 'events.id')
            ->where('user_event_clicks.created_at', '>=', now()->subDays(30));

        if ($userId) {
            $clickQuery->where('user_event_clicks.ip_address', $ipAddress); 
        } else {
            $clickQuery->where('user_event_clicks.ip_address', $ipAddress)
                       ->where('user_event_clicks.user_agent', $userAgent);
        }

        $topCategories = $clickQuery->select('events.category_id', \DB::raw('count(*) as total_clicks'))
            ->groupBy('events.category_id')
            ->orderByDesc('total_clicks')
            ->limit(2)
            ->pluck('events.category_id');

        $isPersonalized = false;
        
        // 👇 1. SARINGAN TANGGAL UNTUK RAK REKOMENDASI 👇
        $recommendedQuery = Event::with(['eventOrganizer', 'category'])
            ->where('status', 'approved')
            ->where('end_date', '>=', today()); // Event kedaluwarsa dilarang masuk rekomendasi

        if ($topCategories->isNotEmpty()) {
            $recommendedQuery->whereIn('category_id', $topCategories);
            $isPersonalized = true;
        }

        $recommendedEvents = $recommendedQuery->get()->map(function ($event) {
            $points = 0;
            if ($event->created_at && $event->created_at->diffInDays(now()) <= 3) {
                $points += 15;
            }
            $endDate = \Carbon\Carbon::parse($event->end_date);
            if (now()->diffInDays($endDate) <= 3) {
                $points += 20;
            }
            $event->trending_points = $points;
            return $event;
        })->sortByDesc('trending_points')->take(5)->map(function ($event) {
            return $this->formatEvent($event);
        })->values();

        // 👇 2. SARINGAN TANGGAL UNTUK DAFTAR UTAMA (SEMUA EVENT) 👇
        $allEvents = Event::with(['eventOrganizer', 'category'])
            ->where('status', 'approved')
            ->where('end_date', '>=', today()) // 👈 INI KUNCI PENYELAMATNYA BOS!
            ->latest()
            ->get()
            ->map(function ($event) {
                return $this->formatEvent($event);
            });

        return response()->json([
            'success' => true,
            'is_personalized' => $isPersonalized,
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

            // 👇 1. SINKRONISASI VALIDASI: Hapus aturan 'integer' pada category_id agar bisa menerima string 'other'
            $request->validate([
                'event_title' => 'required|string|max:255',
                'category_id' => 'required', // 👈 Mengikuti standarisasi web
                'start_date' => 'required|date',
                'event_description' => 'required|string',
            ]);

            $status = 'pending'; 
            $organizerId = null;
            $organizerType = 'UKM / Himpunan'; 
            $organizerName = $user->name;

            // 👇 2. LOGIKA KATEGORI ADAPTASI DARI KODE WEB BOS 👇
            $finalCategoryId = null;

            if ($request->category_id === 'other' || !is_numeric($request->category_id)) {
                // Membuat kategori baru berstatus pending (Persis seperti kodingan web bos)
                $newCat = \App\Models\Category::firstOrCreate(
                    ['name' => $request->new_category_name],
                    ['status' => 'pending'] // Menunggu restu Admin biar ga langsung mengotori database
                );
                $finalCategoryId = $newCat->id;
            } else {
                $finalCategoryId = $request->category_id;
            }
            // 👆 BATAS LOGIKA ADAPTASI WEB 👆

            // Logika pengecekan role Admin / EO mobile
            $isAdmin = \App\Models\AccountRole::where('user_id', $user->id)->where('role_id', 1)->exists();
            if ($isAdmin) {
                $status = 'approved';
                $organizerName = 'Admin Univent';
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
                $eo = \App\Models\EventOrganizer::where('user_id', $user->id)->first();
                if (!$eo) {
                    $isRoleEo = \App\Models\AccountRole::where('user_id', $user->id)->where('role_id', 2)->exists();
                    if ($isRoleEo) {
                        $eo = \App\Models\EventOrganizer::create([
                            'user_id' => $user->id,
                            'name' => 'Organizer ' . $user->name,
                            'contact_email' => $user->email,
                        ]);
                    } else {
                        return response()->json(['success' => false, 'message' => 'Akun Anda tidak terdaftar sebagai EO.'], 403);
                    }
                }
                $organizerId = $eo->id;
                $organizerName = $eo->name;
            }

            $posterPath = 'default_poster.png'; 
            if ($request->hasFile('event_poster')) {
                $posterPath = $request->file('event_poster')->store('posters', 'public');
            }

            // Simpan data event baru ke database
            $event = \App\Models\Event::create([
                'event_organizer_id' => $organizerId,
                'organizer_type' => $organizerType,
                'organizer_name' => $organizerName,
                'category_id' => $finalCategoryId, // 👈 ID Kategori hasil saringan di atas
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
                'event_poster' => $posterPath, 
            ]);

            // Pemicu FCM Notifikasi ke Admin
            if (!$isAdmin) {
                $adminIds = \App\Models\AccountRole::where('role_id', 1)->pluck('user_id');
                $admins = \App\Models\User::whereIn('id', $adminIds)->get();
                if ($admins->count() > 0) {
                    foreach ($admins as $admin) {
                        FcmService::sendNotification(
                            $admin->fcm_token, 
                            'Pengajuan Event Baru 📅', 
                            'Terdapat pengajuan event baru via HP: ' . $event->event_title,
                            [
                                'tipe' => 'pengajuan_event',
                                'event_id' => (string) $event->id
                            ]
                        );
                    }
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Event berhasil diajukan via Mobile!',
                'data' => $event
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Gagal submit via API: ' . $e->getMessage()], 500);
        }
    }
    public function getEventDetail($id)
    {
        try {
            // 👇 PELACAK KLIK GAIB ANTI-CRASH 👇
            // Menggunakan updateOrInsert agar terhindar dari Error Unique Key di Database
            \DB::table('user_event_clicks')->updateOrInsert(
                [
                    'event_id' => $id,
                    'ip_address' => request()->ip(),
                    'user_agent' => request()->userAgent()
                ],
                [
                    'created_at' => now(),
                    'updated_at' => now(),
                ]
            );
            // 👆 BATAS PELACAK 👆

            $event = \App\Models\Event::with('eventOrganizer')->find($id);

            if (!$event) {
                return response()->json([
                    'success' => false, 
                    'message' => 'Data event tidak ditemukan di database.'
                ], 404);
            }

            $data = [
                'id' => $event->id,
                'status' => $event->status ?? 'pending',
                'event_title' => $event->event_title ?? 'Tanpa Judul',
                'event_poster' => $event->event_poster,
                'category_name' => $event->category->name ?? 'Event Category', 
                'organizer_type' => strtoupper($event->organizer_type ?? 'ORGANIZATION'),
                'organizer_name' => $event->organizer_name ?? ($event->eventOrganizer->name ?? 'Admin Univent'),
                'start_date' => $event->start_date ? \Carbon\Carbon::parse($event->start_date)->translatedFormat('d M Y') : '-',
                'end_date' => $event->end_date ? \Carbon\Carbon::parse($event->end_date)->translatedFormat('d M Y') : '-',
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

            // Cari tahu siapa pemilik event ini berdasarkan event_organizer_id
            $organizer = \App\Models\EventOrganizer::find($event->event_organizer_id);
            
            // Jika pemiliknya ketemu dan bukan Admin yang lagi login, kirim notif
            if ($organizer && $organizer->user_id !== $user->id) {
                $pemilikEvent = \App\Models\User::find($organizer->user_id);
                if ($pemilikEvent) {
                    // Pastikan kamu punya file notifikasi EventStatusNotification
                    $pesanStatus = $request->status == 'approved' ? 'Disetujui' : 'Ditolak';
                    $pemilikEvent->notify(new \App\Notifications\EventStatusNotification($event, $pesanStatus));
                    $judulNotif = $request->status == 'approved' ? 'Event Disetujui! 🎉' : 'Event Ditolak 😔';
                    $teksNotif = $request->status == 'approved' ? 'Event kamu sudah tayang di Univent.' : 'Mohon maaf, event kamu ditolak.';
                    FcmService::sendNotification($pemilikEvent->fcm_token, $judulNotif, $teksNotif);
                }
            }

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
    public function generateDescription(Request $request)
    {
        $apiKey = env('GEMINI_API_KEY');

        if (!$apiKey) {
            return response()->json(['success' => false, 'message' => 'API Key tidak ditemukan.'], 500);
        }

        // Memakai model gemini-2.5-flash persis seperti web bos
        $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" . $apiKey;

        $prompt = "Buatkan deskripsi acara yang sangat menarik untuk mahasiswa Telkom University Purwokerto. 
        Judul Event: '{$request->title}'
        Kategori: '{$request->category_name}'.";

        try {
            $response = \Illuminate\Support\Facades\Http::withoutVerifying()->post($url, [
                'contents' => [
                    ['parts' => [['text' => $prompt]]]
                ]
            ]);

            if ($response->successful()) {
                $result = $response->json();
                $description = $result['candidates'][0]['content']['parts'][0]['text'] ?? 'Gagal generate teks.';
                
                return response()->json([
                    'success' => true, 
                    'description' => trim($description)
                ]);
            }

            return response()->json([
                'success' => false, 
                'message' => 'Server AI Google sedang sibuk, silakan coba beberapa saat lagi!'
            ], 500);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }
}