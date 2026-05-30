<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\AccountRole;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // ==========================================
        // 1. BUAT AKUN EO (EVENT ORGANIZER)
        // ==========================================
        $eo = User::firstOrCreate(
            ['email' => 'yhota140405@gmail.com'],
            [
                'name'              => 'Akun EO Tester',
                'password'          => Hash::make('password123'),
                'email_verified_at' => now(),
                
                // Data khusus EO agar langsung "Approved"
                'eo_request_status' => 'approved',
                'eo_org_type'       => 'Internal Kampus',
                'eo_org_name'       => 'BEM Telkom Purwokerto',
                'eo_pic_name'       => 'Ketua BEM',
                'eo_phone'          => '081234567890',
                'eo_instagram'      => 'bem_telkom',
            ]
        );

        // Pasangkan role EO (id = 2) menggunakan AccountRole
        AccountRole::firstOrCreate(
            ['user_id' => $eo->id, 'role_id' => 2],
            ['created_at' => now(), 'updated_at' => now()]
        );

        // ==========================================
        // 2. BUAT AKUN USER BIASA
        // ==========================================
        $user = User::firstOrCreate(
            ['email' => 'yogahogantara@gmail.com'],
            [
                'name'              => 'Mahasiswa Biasa',
                'password'          => Hash::make('password123'),
                'email_verified_at' => now(),
                'eo_request_status' => 'none',
            ]
        );

        // Pasangkan role User (id = 2) menggunakan AccountRole
        AccountRole::firstOrCreate(
            ['user_id' => $user->id, 'role_id' => 3],
            ['created_at' => now(), 'updated_at' => now()]
        );
    }
}