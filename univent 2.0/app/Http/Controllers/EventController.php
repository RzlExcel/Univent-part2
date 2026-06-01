<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\EventRegistration;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\View\View;
use Illuminate\Http\RedirectResponse;
use Carbon\Carbon; 
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Storage;
use App\Services\FcmService; 

class EventController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth')->only([
            'create',
            'store',
            'update',
            'showHistory',
            'showRegistration',
        ]);
    }

    protected function redirectTo(Request $request): ?string
    {
        return $request->expectsJson() ? null : route('login');
    }

    public function create(Request $request): View|RedirectResponse
    {
        $event = null;

        if ($request->has('edit')) {
            $eventId = $request->query('edit');
            /** @var Event $event */
            $event = Event::findOrFail($eventId);

            $isOwner = EventRegistration::where('event_id', $event->id)
                ->where('user_id', Auth::id())
                ->exists();

            if (! $isOwner) {
                return redirect()->route('user.event.history')->with('error', 'Anda tidak berhak mengubah event ini.');
            }

            if ($event->status !== 'pending') {
                return redirect()->route('user.event.history')->with('error', 'Event yang sudah disetujui tidak dapat diubah.');
            }
        }
        
        $categories = \App\Models\Category::where('status', 'approved')->get();
        $eo = \App\Models\EventOrganizer::where('user_id', Auth::id())->first();
        return view('submit-event', compact('event', 'categories', 'eo'));
    }

    public function store(Request $request): RedirectResponse
    {
        $request->validate([
            'event_title' => 'required|string|max:255',
            'organizer_type' => 'required|string',
            'category_id' => 'required',
            'event_description' => 'required|string',
            'start_date' => 'required|date',
            'start_time' => 'required',
            'end_date' => 'required|date|after_or_equal:start_date',
            'end_time' => 'required',
            'event_location' => 'required|string',
            'registration_link' => 'nullable|url',
            'contact_person' => 'required|string',
            'event_poster' => 'required|image|mimes:jpg,jpeg,png|max:4096', 
        ]);

        $user = Auth::user();

        $eo = \App\Models\EventOrganizer::where('user_id', $user->id)->first();
        if (!$eo) {
            $eo = \App\Models\EventOrganizer::create([
                'user_id' => $user->id,
                'name' => $user->name, 
                'description' => $request->organizer_type,
            ]);
        }

        $finalCategoryId = null;
        $categoryName = '';

        if ($request->category_id === 'other') {
            $newCat = \App\Models\Category::firstOrCreate(
                ['name' => $request->new_category_name],
                ['status' => 'pending'] 
            );
            $finalCategoryId = $newCat->id;
            $categoryName = $newCat->name;
        } else {
            $finalCategoryId = $request->category_id;
            $cat = \App\Models\Category::find($request->category_id);
            $categoryName = $cat ? $cat->name : 'Unknown';
        }

        // --- UBAH MENJADI FILE STORAGE MURNI ---
        $posterPath = null;
        if ($request->hasFile('event_poster')) {
            // Langsung simpan file ke storage/app/public/posters
            $posterPath = $request->file('event_poster')->store('posters', 'public');
        }

        $event = Event::create([
            'user_id' => $user->id,
            'event_organizer_id' => $eo->id,
            'category_id' => $finalCategoryId,
            'event_title' => $request->event_title,
            'organizer_name' => $user->name, 
            'organizer_type' => $request->organizer_type, 
            'event_category' => $categoryName,
            'event_description' => $request->event_description,
            'start_date' => $request->start_date,
            'start_time' => $request->start_time,
            'end_date' => $request->end_date,
            'end_time' => $request->end_time,
            'event_location' => $request->event_location,
            'registration_link' => $request->registration_link,
            'contact_person' => $request->contact_person,
            'event_poster' => $posterPath, // <- Masukkan path gambar di sini
            'status' => 'pending',
        ]);

        if (Auth::check()) {
            EventRegistration::create([
                'user_id' => Auth::id(),
                'event_id' => $event->id,
                'status' => 'pending',
            ]);
        }
        
        if ($user->id != 1) {
            $admins = \App\Models\User::where('id', 1)->get(); 
            if ($admins->count() > 0) {
                \Illuminate\Support\Facades\Notification::send($admins, new \App\Notifications\NewEventSubmittedNotification($event));
                foreach ($admins as $admin) {
                    FcmService::sendNotification(
                        $admin->fcm_token, 
                        'Pengajuan Event Baru 📅', 
                        'Terdapat pengajuan event baru via Web dari ' . $user->name
                    );
                }
            }
        } else {
            // (Opsional) Jika Admin yang bikin event, statusnya bisa langsung di-approve
            $event->update(['status' => 'approved']);
            
            // Atau cukup biarkan saja tanpa mengirim notif "menunggu persetujuan"
        }

        return redirect()->route('dashboard')->with('success', 'Event berhasil disubmit dan terdaftar!');
    }

    public function update(Request $request, int $id): RedirectResponse
    {
        $request->validate([
            'event_title' => 'required|string|max:255',
            'organizer_type' => 'required|string', 
            'category_id' => 'required',
            'event_description' => 'required|string',
            'start_date' => 'required|date',
            'start_time' => 'required',
            'end_date' => 'required|date|after_or_equal:start_date',
            'end_time' => 'required',
            'event_location' => 'required|string',
            'registration_link' => 'nullable|url',
            'contact_person' => 'required|string',
            'event_poster' => 'nullable|image|mimes:jpg,jpeg,png|max:4096', 
        ]);

        $event = Event::findOrFail($id);
        $user = Auth::user();

        if ($event->status !== 'pending') {
            return redirect()->route('user.event.history')->with('error', 'Event yang sudah disetujui tidak dapat diubah.');
        }

        $isOwner = EventRegistration::where('event_id', $event->id)
            ->where('user_id', $user->id)
            ->exists();

        if (! $isOwner) {
            return redirect()->route('user.event.history')->with('error', 'Anda tidak berhak mengubah event ini.');
        }

        $eo = \App\Models\EventOrganizer::where('user_id', $user->id)->first();
        if (!$eo) {
            $eo = \App\Models\EventOrganizer::create([
                'user_id' => $user->id,
                'name' => $user->name,
                'description' => $request->organizer_type,
            ]);
        } else {
            $eo->update(['description' => $request->organizer_type]);
        }

        $finalCategoryId = null;
        $categoryName = '';

        if ($request->category_id === 'other') {
            $newCat = \App\Models\Category::firstOrCreate(
                ['name' => $request->new_category_name],
                ['status' => 'pending']
            );
            $finalCategoryId = $newCat->id;
            $categoryName = $newCat->name;
        } else {
            $finalCategoryId = $request->category_id;
            $cat = \App\Models\Category::find($request->category_id);
            $categoryName = $cat ? $cat->name : 'Unknown';
        }

        // --- UBAH MENJADI FILE STORAGE MURNI & HAPUS FILE LAMA ---
        $posterPath = $event->event_poster;
        if ($request->hasFile('event_poster')) {
            // Jika poster lama bukan base64 (string pendek), hapus fisik file lamanya
            if ($posterPath && strlen($posterPath) < 200) {
                Storage::disk('public')->delete($posterPath);
            }
            
            // Simpan gambar yang baru
            $posterPath = $request->file('event_poster')->store('posters', 'public');
        }

        $event->update([
            'event_organizer_id' => $eo->id,
            'category_id' => $finalCategoryId,
            'event_title' => $request->event_title,
            'organizer_name' => $user->name, 
            'organizer_type' => $request->organizer_type,
            'event_category' => $categoryName,
            'event_description' => $request->event_description,
            'start_date' => $request->start_date,
            'start_time' => $request->start_time,
            'end_date' => $request->end_date,
            'end_time' => $request->end_time,
            'event_location' => $request->event_location,
            'registration_link' => $request->registration_link,
            'contact_person' => $request->contact_person,
            'event_poster' => $posterPath, // <- Masukkan path gambar di sini
        ]);

        return redirect()->route('user.event.history')->with('success', 'Event berhasil diperbarui!');
    }

    public function index(): View
    {
        $activeEvents = Event::where('status', 'approved')
            ->where('end_date', '>=', today())
            ->withCount('clicks') 
            ->get();

        $trendingEvents = $activeEvents->map(function ($event) {
            $points = $event->clicks_count * 5;

            if ($event->created_at && $event->created_at->diffInDays(now()) <= 3) {
                $points += 15;
            }

            $endDate = Carbon::parse($event->end_date);
            if (now()->diffInDays($endDate) <= 3) {
                $points += 20;
            }

            $event->trending_points = $points;
            
            return $event;
        })
        ->sortByDesc('trending_points') 
        ->take(3); 

        $events = Event::where('status', 'approved')->latest()->get();

        return view('dashboard.dashboard', compact('trendingEvents', 'events'));
    }

    public function show(Request $request, int $id): View 
    {
        $event = Event::findOrFail($id);

        $ipAddress = $request->ip();
        $userAgent = $request->userAgent();

        DB::table('user_event_clicks')->updateOrInsert(
            [
                'event_id' => $event->id,
                'ip_address' => $ipAddress,
                'user_agent' => $userAgent
            ],
            [
                'created_at' => now(), 
                'updated_at' => now()
            ]
        );

        return view('event-detail', compact('event'));
    }

    public function browse(Request $request): View 
    {
        $search = $request->query('search'); 
        $category = $request->query('category');
        $organizer = $request->query('organizer');

        $recommendedEvents = collect(); 
        $isPersonalized = false; 

        $mainCategories = ['Seminar', 'Workshop', 'Competition', 'Gathering'];

        $applyFilters = function ($query) use ($search, $category, $organizer, $mainCategories) {
            if ($search) {
                $query->where(function ($q) use ($search) {
                    $q->where('event_title', 'LIKE', "%{$search}%")
                      ->orWhere('event_location', 'LIKE', "%{$search}%")
                      ->orWhere('event_description', 'LIKE', "%{$search}%");
                });
            }

            if ($category) {
                if ($category === 'Other') {
                    $mainCatIds = \App\Models\Category::whereIn('name', $mainCategories)->pluck('id');
                    $query->whereNotIn('category_id', $mainCatIds);
                } else {
                    $catId = \App\Models\Category::where('name', $category)->value('id');
                    $query->where('category_id', $catId);
                }
            }

            if ($organizer) {
                $query->where('organizer_type', $organizer);
            }
        };

        $eventsQuery = Event::where('status', 'approved')
            ->where('end_date', '>=', today());
            
        $applyFilters($eventsQuery); 
        
        $events = $eventsQuery->latest()->get();

        $ipAddress = $request->ip();
        $userAgent = $request->userAgent();

        $topCategories = DB::table('user_event_clicks')
            ->join('events', 'user_event_clicks.event_id', '=', 'events.id')
            ->where('user_event_clicks.ip_address', $ipAddress)
            ->where('user_event_clicks.user_agent', $userAgent)
            ->where('user_event_clicks.created_at', '>=', now()->subDays(30))
            ->select('events.category_id', DB::raw('count(*) as total_clicks'))
            ->groupBy('events.category_id')
            ->orderByDesc('total_clicks')
            ->limit(2)
            ->pluck('events.category_id');

        if ($topCategories->isNotEmpty()) {
            $recommendedQuery = Event::where('status', 'approved')
                ->whereIn('category_id', $topCategories)
                ->where('end_date', '>=', today())
                ->withCount('clicks'); 

            $applyFilters($recommendedQuery); 

            $recommendedEvents = $recommendedQuery->get()->map(function ($event) {
                $points = $event->clicks_count * 5; 
                
                if ($event->created_at && $event->created_at->diffInDays(now()) <= 3) {
                    $points += 15; 
                }
                
                $endDate = Carbon::parse($event->end_date);
                if (now()->diffInDays($endDate) <= 3) {
                    $points += 20; 
                }
                
                $event->trending_points = $points;
                return $event;
            })->sortByDesc('trending_points')->take(6);
            
            if ($recommendedEvents->isNotEmpty()) {
                $isPersonalized = true;
            }
        }

        if ($recommendedEvents->isEmpty()) {
            $coldStartQuery = Event::where('status', 'approved')
                ->where('end_date', '>=', today())
                ->withCount('clicks'); 
            
            $applyFilters($coldStartQuery); 

            $recommendedEvents = $coldStartQuery->get()->map(function ($event) {
                $points = $event->clicks_count * 5; 
                
                if ($event->created_at && $event->created_at->diffInDays(now()) <= 3) {
                    $points += 15; 
                }
                
                $endDate = Carbon::parse($event->end_date);
                if (now()->diffInDays($endDate) <= 3) {
                    $points += 20; 
                }
                
                $event->trending_points = $points;
                return $event;
            })->sortByDesc('trending_points')->take(6);
        }

        return view('browse-events', compact('recommendedEvents', 'events', 'isPersonalized', 'search'));
    }

    public function showHistory(): View|RedirectResponse
    {
        if (! Auth::check()) {
            return redirect()->route('login');
        }
        $userId = Auth::id();
        $registrations = EventRegistration::where('user_id', $userId)
            ->with('event')
            ->latest()
            ->paginate(10);

        return view('event-history', compact('registrations'));
    }

    public function showRegistration(int $id): View
    {
        $registration = EventRegistration::with('event')
            ->where('user_id', Auth::id())
            ->findOrFail($id);

        return view('registration-detail', compact('registration'));
    }

    public function generateDescription(Request $request)
    {
        $apiKey = env('GEMINI_API_KEY');

        if (!$apiKey) {
            return response()->json(['success' => false, 'message' => 'API Key tidak ditemukan.'], 500);
        }

        $url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" . $apiKey;

        $prompt = "Buatkan deskripsi acara yang sangat menarik untuk mahasiswa Telkom University Purwokerto. 
        Judul Event: '{$request->title}'
        Kategori: '{$request->category_name}'.";

        try {
            $response = Http::withoutVerifying()->post($url, [
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
                'message' => 'Gagal: ' . $response->body()
            ], 500);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => $e->getMessage()], 500);
        }
    }

}