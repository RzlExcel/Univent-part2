import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/home_kerangka.dart';
import '../services/event_service.dart'; // Impor service event baru
import 'browse_event_page.dart';
import 'submit_event_page.dart';
import 'profile_page.dart';
import 'login_page.dart';
import 'notification_page.dart';
import '../services/api_notification_service.dart';

class UniventHomePage extends StatefulWidget {
  final bool isLoggedIn;

  const UniventHomePage({super.key, this.isLoggedIn = false});

  @override
  State<UniventHomePage> createState() => _UniventHomePageState();
}

class _UniventHomePageState extends State<UniventHomePage> {
  int _selectedIndex = 0;
  final ApiEventService _eventService = ApiEventService();
  late Future<Map<String, dynamic>> _homeDataFuture;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    // Inisialisasi pengambilan data dari server saat halaman pertama dibuka
    _homeDataFuture = _eventService.fetchHomeData();

    if (widget.isLoggedIn) {
      _fetchUnreadCount();
    }
  }

  // Fungsi untuk menarik angka
  Future<void> _fetchUnreadCount() async {
    final count = await ApiNotificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  // Fungsi refresh manual jika user menarik layar ke bawah (Pull to Refresh)
  Future<void> _refreshData() async {
    setState(() {
      _homeDataFuture = _eventService.fetchHomeData();
    });
  }

  Widget _buildBodyContent() {
    if (_selectedIndex == 0) {
      return FutureBuilder<Map<String, dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              ),
            );
          }

          if (snapshot.hasError || snapshot.data?['success'] != true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    snapshot.data?['message'] ??
                        "Gagal terhubung ke server backend.",
                  ),
                  TextButton(
                    onPressed: _refreshData,
                    child: const Text(
                      "Coba Lagi",
                      style: TextStyle(color: AppTheme.primaryPink),
                    ),
                  ),
                ],
              ),
            );
          }

          // Ekstraksi data sukses dari Laravel JSON response
          final data = snapshot.data!;
          final stats = data['stats'];
          final List recommendedList = data['recommended'] ?? [];
          final List allEventsList = data['all_events'] ?? [];

          return RefreshIndicator(
            onRefresh: _refreshData,
            color: AppTheme.primaryPink,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // 1. Hero Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Telkom University Purwokerto",
                          style: TextStyle(
                            color: AppTheme.greyText,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Discover Campus",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.darkBlue,
                            height: 1.1,
                          ),
                        ),
                        const Text(
                          "Events Here",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryPink,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Statistics Row (Menggunakan data dinamis backend)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        HomeKerangka.statItem(
                          Icons.event_available,
                          stats['total_events'] ?? "0",
                          "Events Active",
                        ),
                        HomeKerangka.statItem(
                          Icons.corporate_fare,
                          stats['total_organizers'] ?? "0",
                          "Organizers",
                        ),
                        HomeKerangka.statItem(
                          Icons.people_alt_outlined,
                          stats['total_users'] ?? "0",
                          "Members",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 3. Recommended / FYP Section
                  if (recommendedList.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: HomeKerangka.sectionTitle(
                        "Rekomendasi Khusus",
                        showSeeAll: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 380,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        scrollDirection: Axis.horizontal,
                        itemCount: recommendedList.length,
                        itemBuilder: (context, index) {
                          final ev = recommendedList[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 16.0),
                            child: SizedBox(
                              width: 280,
                              child: HomeKerangka.eventCard(
                                context: context,
                                eventId: ev['id'],
                                title: ev['title'],
                                organizer: ev['organizer'],
                                date: ev['date'],
                                location: ev['location'],
                                posterPath: ev['poster'],
                                isRecommended: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 4. All Events List Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: HomeKerangka.sectionTitle(
                      "Semua Event Kampus",
                      showSeeAll: false,
                    ),
                  ),
                  const SizedBox(height: 16),

                  allEventsList.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            "Belum ada event aktif saat ini.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: allEventsList.length,
                          itemBuilder: (context, index) {
                            final ev = allEventsList[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: HomeKerangka.eventCard(
                                context: context,
                                eventId: ev['id'],
                                title: ev['title'],
                                organizer: ev['organizer'],
                                date: ev['date'],
                                location: ev['location'],
                                posterPath: ev['poster'],
                                isRecommended: false,
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
      );
    } else if (_selectedIndex == 1) {
      return const BrowseEventPage();
    } else if (_selectedIndex == 2) {
      return const SubmitEventPage();
    } else if (_selectedIndex == 3) {
      return const ProfilePage();
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: HomeKerangka.univentLogo(),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          // 1. Jika belum login dan sedang di tab Home (index 0)
          if (!widget.isLoggedIn && _selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPink,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  "Login",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

          // 2. Jika sudah login
          if (widget.isLoggedIn) ...[
            Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7FA),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: AppTheme.darkBlue,
                      size: 22,
                    ),
                    onPressed: () async {
                      // Gunakan await agar saat kembali dari halaman notif, angka di-refresh
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationPage(),
                        ),
                      );
                      // Refresh angka notifikasi jadi 0 setelah dibaca semua
                      _fetchUnreadCount();
                    },
                  ),
                  // Titik merah hanya muncul kalau ada yang belum dibaca (> 0)
                  if (_unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          _unreadCount > 9
                              ? '9+'
                              : '$_unreadCount', // Jika lebih dari 9, tampilkan 9+
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F7FA),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.person_outline,
                  color: AppTheme.darkBlue,
                  size: 22,
                ),

                // Saat diklik, langsung pindah ke tab Profile (index 3)
                onPressed: () => setState(() => _selectedIndex = 3),
              ),
            ),
          ],
        ],
      ),

      body: _buildBodyContent(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (!widget.isLoggedIn && (index == 2 || index == 3)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } else {
                setState(() => _selectedIndex = index);
              }
            },
            selectedItemColor: AppTheme.primaryPink,
            unselectedItemColor: Colors.grey.shade400,
            type: BottomNavigationBarType.fixed,
            showUnselectedLabels: true,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  widget.isLoggedIn ? Icons.search : Icons.explore_outlined,
                ),
                label: widget.isLoggedIn ? "Events" : "Browse",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.add_box_outlined),
                label: "Submit",
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
