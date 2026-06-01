import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import 'home_page.dart';
import 'event_history_page.dart';
import 'event_list_management_page.dart';
import 'eo_upgrade_page.dart';
import 'admin_eo_request_page.dart';
import 'contact_us_page.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    // Menggunakan ApiAuthService yang sudah dijamin akurat
    _profileFuture = ApiAuthService.getUserProfile();
  }

  // 👇 SENJATA 1: Fungsi Tarik untuk Refresh Manual 👇
  Future<void> _refreshProfile() async {
    setState(() {
      _profileFuture = ApiAuthService.getUserProfile();
    });
    await _profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          if (snapshot.hasError || snapshot.data?['success'] != true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_person_outlined,
                    size: 50,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Silakan login terlebih dahulu untuk melihat profil.",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryPink,
                    ),
                    child: const Text(
                      "Log In",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final userData = snapshot.data!['user'];
          final String userRole = (userData['role'] ?? 'USER')
              .toString()
              .toUpperCase();
          final String eoStatus = (userData['eo_request_status'] ?? 'none')
              .toString();

          return RefreshIndicator(
            color: AppTheme.primaryPink,
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics:
                  const AlwaysScrollableScrollPhysics(), // Wajib agar layar selalu bisa ditarik
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20.0,
              ),
              child: Column(
                children: [
                  // --- 1. KARTU PROFIL UTAMA ---
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // 👇 TAMPILAN FOTO AVATAR DINAMIS 👇
                        // --- 👇 Ganti seluruh Container foto profil dengan ini 👇 ---
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child:
                                (userData['avatar'] == null ||
                                    userData['avatar'] == 'Belum diatur')
                                ? const Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.grey,
                                  )
                                : CachedNetworkImage(
                                    imageUrl:
                                        "http://10.0.2.2:8000/storage/${userData['avatar']}",
                                    fit: BoxFit.cover,
                                    // PENTING: cacheKey tetap kita pakai agar tidak download ulang
                                    // jika path filenya sama (seperti yang sudah kita bahas sebelumnya)
                                    cacheKey: userData['avatar'],
                                    placeholder: (context, url) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Colors.grey,
                                        ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          userData['name'] ?? "User Univent",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.darkBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userRole,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem("0", "EVENTS"),
                            _buildStatItem("0", "HISTORY"),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Divider(color: Colors.grey.shade200),
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 👇 DATA PRIBADI DINAMIS 👇
                        _buildInfoRow(
                          Icons.email_outlined,
                          "EMAIL ADDRESS",
                          userData['email'] ?? "Tidak diatur",
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.access_time,
                          "BIRTHDAY",
                          userData['birthday'] ?? "Belum diatur",
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.phone_outlined,
                          "PHONE NUMBER",
                          userData['phone'] ?? "Belum diatur",
                        ),
                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const EditProfilePage(),
                                    ),
                                  );

                                  // Jika disave, load ulang profil otomatis!
                                  if (result == true) {
                                    _refreshProfile();
                                  }
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Edit Profile",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryPink,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 2,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  ApiAuthService.token = null;
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const UniventHomePage(
                                            isLoggedIn: false,
                                          ),
                                    ),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(
                                  Icons.logout,
                                  size: 16,
                                  color: AppTheme.darkBlue,
                                ),
                                label: const Text(
                                  "Log Out",
                                  style: TextStyle(
                                    color: AppTheme.darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- 2. KARTU MENU BAWAH ---
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (userRole == 'ADMIN') ...[
                          _buildMenuItem(
                            Icons.calendar_today_outlined,
                            "Event List Management",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EventListManagementPage(),
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey.shade100, height: 1),
                          _buildMenuItem(
                            Icons.access_time,
                            "Event History",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventHistoryPage(),
                              ),
                            ),
                          ),
                          _buildMenuItem(
                            Icons.group_add_outlined,
                            "Persetujuan Akun EO",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const AdminEoRequestPage(),
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey.shade100, height: 1),
                        ] else if (userRole == 'EO') ...[
                          _buildMenuItem(
                            Icons.access_time,
                            "Event History",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventHistoryPage(),
                              ),
                            ),
                          ),
                          Divider(color: Colors.grey.shade100, height: 1),
                          _buildMenuItem(
                            Icons.mail_outline,
                            "Contact Us",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactUsPage(),
                              ),
                            ),
                          ),
                        ] else ...[
                          if (eoStatus == 'pending')
                            _buildMenuItem(
                              Icons.hourglass_top,
                              "Upgrade to EO (Pending)",
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Pengajuan Anda sedang diproses oleh Admin.",
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            _buildMenuItem(
                              Icons.campaign_outlined,
                              "Upgrade to Event Organizer",
                              onTap: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const EoUpgradePage(),
                                  ),
                                );
                                if (result == true) {
                                  _refreshProfile();
                                }
                              },
                            ),
                          Divider(color: Colors.grey.shade100, height: 1),
                          _buildMenuItem(
                            Icons.mail_outline,
                            "Contact Us",
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactUsPage(),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET CETAKAN ASLI ---
  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.darkBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightPinkBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryPink, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.darkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, color: AppTheme.primaryPink, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.darkBlue,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}
