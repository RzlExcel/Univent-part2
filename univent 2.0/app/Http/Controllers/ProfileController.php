<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\View\View; 
use Illuminate\Http\RedirectResponse; 
use App\Models\User;
use App\Models\Role; // Fix: Menggunakan huruf kapital 'R' untuk standar model Laravel
use Illuminate\Support\Facades\Storage; // <-- Wajib ditambahkan untuk hapus file fisik
use App\Services\FcmService;

class ProfileController extends Controller
{
    /**
     * Menampilkan halaman profil pengguna.
     */
    public function show(): View|RedirectResponse
    {
        /** @var \App\Models\User|null $user */
        $user = Auth::user();

        if (! $user) {
            return redirect()->route('login');
        }

        $user->load('profile');

        return view('profile', compact('user'));
    }

    /**
     * Menampilkan halaman edit profil.
     */
    public function edit(): View|RedirectResponse
    {
        /** @var \App\Models\User|null $user */
        $user = Auth::user();

        if (! $user) {
            return redirect()->route('login');
        }

        $user->load('profile');

        return view('edit-profile', compact('user'));
    }

    /**
     * Update profil (avatar, birthday, phone)
     */
    public function updateProfile(Request $request): RedirectResponse
    {
        /** @var \App\Models\User|null $user */
        $user = Auth::user();

        if (! $user) {
            return redirect()->route('login');
        }

        // UBAH VALIDASI: Ganti new_avatar_temp menjadi avatar_file (Upload Fisik)
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'nullable|string|max:15|regex:/^(\+?\d{1,15})$/',
            'birthday' => 'nullable|date',
            'avatar_file' => 'nullable|image|mimes:jpeg,png,jpg|max:2048', 
            'remove_avatar' => 'nullable|boolean',
        ]);

        $user->name = $validated['name'];

        /*
        |--------------------------------------------------------------------------
        | HANDLE AVATAR (FILE STORAGE MURNI)
        |--------------------------------------------------------------------------
        */

        // Jika user mencentang hapus avatar
        if ($request->remove_avatar == 1) {
            // Hapus file fisik dari folder storage jika BUKAN base64
            if ($user->avatar && strlen($user->avatar) < 200) {
                Storage::disk('public')->delete($user->avatar);
            }
            $user->avatar = null;
        }

        // Jika user meng-upload foto profil baru
        if ($request->hasFile('avatar_file')) {
            // Hapus file fisik lama dulu jika ada dan bukan base64
            if ($user->avatar && strlen($user->avatar) < 200) {
                Storage::disk('public')->delete($user->avatar);
            }
            
            // Simpan foto baru ke folder storage/app/public/avatars
            $path = $request->file('avatar_file')->store('avatars', 'public');
            
            // Simpan path tersebut ke database
            $user->avatar = $path;
        }

        $user->save();

        /*
        |--------------------------------------------------------------------------
        | HANDLE PROFILE DETAIL (phone & birthday)
        |--------------------------------------------------------------------------
        */

        $user->profile()->updateOrCreate(
            ['user_id' => $user->id],
            [
                'birthday' => $validated['birthday'] ?? null,
                'phone' => $validated['phone'] ?? null,
            ]
        );

        return redirect()->route('profile.edit')->with('success', 'Profile berhasil diperbarui!');
    }

   /**
     * Memproses pengajuan user menjadi EO (beserta form verifikasi)
     */
    public function requestEoAccess(Request $request): RedirectResponse
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();

        // Hanya proses jika statusnya belum pending atau belum disetujui
        if ($user->eo_request_status === 'none' || $user->eo_request_status === 'rejected') {
            
            // 1. Validasi Input Form
            $validated = $request->validate([
                'eo_org_type'  => 'required|string|in:Internal Kampus,Eksternal Publik',
                'eo_org_name'  => 'required|string|max:255',
                'eo_pic_name'  => 'required|string|max:255',
                'eo_phone'     => 'required|string|max:20',
                'eo_instagram' => 'nullable|string|max:255',
            ]);

            // 2. Simpan Data ke Database & Ubah Status
            $user->eo_org_type = $validated['eo_org_type'];
            $user->eo_org_name = $validated['eo_org_name'];
            $user->eo_pic_name = $validated['eo_pic_name'];
            $user->eo_phone = $validated['eo_phone'];
            $user->eo_instagram = $validated['eo_instagram'];
            
            $user->eo_request_status = 'pending';
            $user->save();

            // --- TAMBAHAN NOTIFIKASI KE ADMIN ---
            $admins = \App\Models\User::where('id', 1)->get();
            \Illuminate\Support\Facades\Notification::send($admins, new \App\Notifications\NewEoRequestNotification($user));

            foreach ($admins as $admin) {
                FcmService::sendNotification(
                    $admin->fcm_token, 
                    'Pengajuan EO Baru 📢', 
                    $user->name . ' mengajukan diri sebagai EO via Web.',
                    [
                        'tipe' => 'pengajuan_eo' // 👈 TAMBAHKAN TIKET INI
                    ]
                );

            }
            // ------------------------------------

            return back()->with('success', 'Formulir berhasil dikirim! Silakan tunggu Admin menghubungi Anda.');
        }

        return back()->with('error', 'Anda sudah mengajukan akses EO atau sudah menjadi EO.');
    }

    /*
    |--------------------------------------------------------------------------
    | FUNGSI KHUSUS ADMIN: MANAJEMEN PENGAJUAN EO
    |--------------------------------------------------------------------------
    */

    /**
     * Menampilkan halaman tabel pengajuan EO
     */
    public function adminEoRequestList(): View
    {
        // Ambil data user yang pernah mengajukan diri menjadi EO (status selain 'none')
        $allRequests = User::whereIn('eo_request_status', ['pending', 'approved', 'rejected'])->latest()->get();
        
        $pendingRequests = User::where('eo_request_status', 'pending')->latest()->get();
        $approvedRequests = User::where('eo_request_status', 'approved')->latest()->get();
        $rejectedRequests = User::where('eo_request_status', 'rejected')->latest()->get();
        
        return view('admin.eo-requests', compact(
            'allRequests',
            'pendingRequests',
            'approvedRequests',
            'rejectedRequests'
        ));
    }

    /**
     * Menyetujui pengajuan EO
     */
    public function approveEoRequest($id): RedirectResponse
    {
        $user = User::findOrFail($id);
        
        // 1. Update status di tabel users
        $user->eo_request_status = 'approved';
        $user->save();

        // 2. Pastikan role 'eo' ada. Jika tidak ada, buat otomatis.
        $roleEo = \App\Models\Role::firstOrCreate(
            ['name' => 'eo'],
            ['guard_name' => 'web']
        );

        // 3. Pasangkan role ke User ID yang baru ini
        if (!$user->hasRole('eo')) {
            $user->roles()->attach($roleEo->id);
        }

        // --- TAMBAHAN NOTIFIKASI KE USER ---
        $user->notify(new \App\Notifications\EoRequestStatusNotification('approved'));
        // -----------------------------------
        FcmService::sendNotification(
            $user->fcm_token, 
            'Pengajuan EO Disetujui! 🎉', 
            'Selamat, pengajuan Upgrade EO kamu telah disetujui Admin.', // 👈 Koma saja, jangan dikurung dulu
            [
                'tipe' => 'eo_approved' // 👈 KITA BUAT TIKET KHUSUS
            ]
        );


        return back()->with('success', 'Pengajuan EO berhasil disetujui!');
        
    }

    /**
     * Menolak pengajuan EO
     */
    public function rejectEoRequest($id): RedirectResponse
    {
        $user = User::findOrFail($id);
        
        // Ubah status menjadi rejected
        $user->eo_request_status = 'rejected';
        $user->save();

        // --- TAMBAHAN NOTIFIKASI KE USER ---
        $user->notify(new \App\Notifications\EoRequestStatusNotification('rejected'));
        // -----------------------------------
        FcmService::sendNotification($user->fcm_token, 'Pengajuan EO Ditolak 😔', 'Mohon maaf, pengajuan Upgrade EO kamu ditolak.');
        return back()->with('success', 'Pengajuan EO berhasil ditolak.');
    }
}