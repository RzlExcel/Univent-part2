<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Event;
use App\Models\EventRegistration;
use App\Notifications\EventStatusNotification;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View; 
use Illuminate\Http\RedirectResponse; 
use Illuminate\Support\Facades\DB; 
use App\Services\FcmService;

class EventListController extends Controller
{
    public function __construct()
    {
        $this->middleware('auth');

        $this->middleware(function (Request $request, $next) {
            /** @var \App\Models\User|null $user */
            $user = Auth::user();

            if (! $user || ! $user->isAdmin()) {
                abort(403, 'Akses Ditolak. Anda harus menjadi Admin.');
            }

            return $next($request);
        });
    }

    public function index(): View
    {
        $allEvents = Event::orderBy('created_at', 'desc')->get();
        $pendingEvents = Event::where('status', 'pending')->orderBy('created_at', 'desc')->get();
        $approvedEvents = Event::where('status', 'approved')->orderBy('created_at', 'desc')->get();
        $rejectedEvents = Event::where('status', 'rejected')->orderBy('created_at', 'desc')->get();

        return view('admin.event-list', compact(
            'allEvents',
            'pendingEvents',
            'approvedEvents',
            'rejectedEvents'
        ));
    }

    public function approve(int $id): RedirectResponse
    {
        $event = Event::with('eventOrganizer.user')->findOrFail($id);

        DB::transaction(function () use ($event) {
            $event->status = 'approved';
            $event->save();

            EventRegistration::where('event_id', $event->id)->update([
                'status' => 'approved',
            ]);

            if ($event->category_id) {
                $category = \App\Models\Category::find($event->category_id);
                
                if ($category && $category->status === 'pending') {
                    $category->update([
                        'status' => 'approved'
                    ]);
                }
            }

            if ($event->eventOrganizer && $event->eventOrganizer->user) {
                // 👇 FIX: Definisikan variabel $pemilikEvent di sini
                $pemilikEvent = $event->eventOrganizer->user; 

                $pemilikEvent->notify(new \App\Notifications\EventStatusNotification($event, 'approved'));
                
                FcmService::sendNotification(
                    $pemilikEvent->fcm_token,
                    'Event Disetujui! 🎉',
                    'Event "' . $event->event_title . '" kamu sudah tayang di Univent.',
                    [
                        'tipe' => 'status_event',
                        'event_id' => (string) $event->id
                    ]
                );
            }
        });

        return redirect()->route('admin.event-list')
            ->with('success', 'Event ' . $event->event_title . ' berhasil disetujui.');
    }

    public function reject(int $id): RedirectResponse
    {
        $event = Event::with('eventOrganizer.user')->findOrFail($id);

        DB::transaction(function () use ($event) {
            $event->status = 'rejected';
            $event->save();

            EventRegistration::where('event_id', $event->id)->update([
                'status' => 'rejected',
            ]);

            if ($event->eventOrganizer && $event->eventOrganizer->user) {
                // 👇 FIX: Definisikan variabel $pemilikEvent di sini
                $pemilikEvent = $event->eventOrganizer->user;

                $pemilikEvent->notify(new \App\Notifications\EventStatusNotification($event, 'rejected'));
                
                FcmService::sendNotification(
                    $pemilikEvent->fcm_token,
                    'Event Ditolak 😔',
                    'Mohon maaf, event "' . $event->event_title . '" kamu ditolak.',
                    [
                        'tipe' => 'status_event',
                        'event_id' => (string) $event->id
                    ]
                );
            }
        });

        return redirect()->route('admin.event-list')
            ->with('success', 'Event ' . $event->event_title . ' berhasil ditolak.');
    }

    public function show(int $id): View
    {
        $event = Event::with(['registrations', 'eventOrganizer.user', 'category'])->findOrFail($id);

        return view('admin.event-detail', compact('event'));
    }

    public function delete(int $id): RedirectResponse
    {
        $event = Event::findOrFail($id);
        $event->delete();

        return redirect()->back()->with('success', 'Event berhasil dihapus.');
    }
}