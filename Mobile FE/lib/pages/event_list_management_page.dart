import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/submitted_kerangka.dart';
import 'registration_details_page.dart';
import '../services/event_service.dart'; // Wajib ditambahkan untuk akses API

class EventListManagementPage extends StatefulWidget {
  const EventListManagementPage({super.key});

  @override
  State<EventListManagementPage> createState() =>
      _EventListManagementPageState();
}

class _EventListManagementPageState extends State<EventListManagementPage> {
  final ApiEventService _eventService = ApiEventService();
  late Future<Map<String, dynamic>> _adminEventsFuture;

  List<dynamic> _allEvents = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    setState(() => _isLoading = true);

    _adminEventsFuture = _eventService.fetchAdminEvents();
    _adminEventsFuture.then((value) {
      if (mounted) {
        setState(() {
          if (value['success'] == true) {
            _allEvents = value['data'] ?? [];
          } else {
            debugPrint("Error dari Server: ${value['message']}");
          }
          _isLoading = false;
        });
      }
    });
  }

  // Menghitung jumlah event per kategori untuk badge di Tab Bar
  int _countByStatus(String status) {
    if (status == "all") return _allEvents.length;
    return _allEvents.where((e) => e['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Event List Management",
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _adminEventsFuture,
        builder: (context, snapshot) {
          // 1. Tampilan Loading
          if (snapshot.connectionState == ConnectionState.waiting ||
              _isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            );
          }

          // 2. Tampilan Error dari Server
          if (snapshot.hasError || snapshot.data?['success'] != true) {
            return Center(
              child: Text(
                snapshot.data?['message'] ?? "Gagal memuat data dari server.",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          // 3. Tampilan Sukses (Render UI Asli)
          return DefaultTabController(
            length: 4,
            child: Column(
              children: [
                // --- HEADER & SEARCH BAR ---
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.only(
                    left: 24,
                    right: 24,
                    top: 10,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Kelola event yang disubmit oleh pengguna dan tentukan status penayangannya.",
                        style: TextStyle(
                          color: AppTheme.greyText,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Search Bar
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value
                                .toLowerCase(); // 👈 Update state setiap kali ngetik
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search Events...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = "";
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // --- TABS (Dengan angka dinamis) ---
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: TabBar(
                    isScrollable: true,
                    labelColor: AppTheme.primaryPink,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: AppTheme.primaryPink,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    tabs: [
                      Tab(text: "Menunggu (${_countByStatus('pending')})"),
                      Tab(text: "Disetujui (${_countByStatus('approved')})"),
                      Tab(text: "Ditolak (${_countByStatus('rejected')})"),
                      Tab(text: "Semua (${_countByStatus('all')})"),
                    ],
                  ),
                ),

                // --- KONTEN TABS ---
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildAdminEventList(context, status: "pending"),
                      _buildAdminEventList(context, status: "approved"),
                      _buildAdminEventList(context, status: "rejected"),
                      _buildAdminEventList(context, status: "all"),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget list data dinamis dari database
  // Widget list data dinamis dari database
  Widget _buildAdminEventList(BuildContext context, {required String status}) {
    List filteredEvents = _allEvents.where((e) {
      // 1. Cek kecocokan Tab Status
      bool matchesStatus = status == "all" || e['status'] == status;

      // 2. Cek kecocokan Kata Kunci Pencarian (Cari di Judul atau Organizer)
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final title = (e['title'] ?? "").toString().toLowerCase();
        final organizer = (e['organizer'] ?? "").toString().toLowerCase();

        matchesSearch =
            title.contains(_searchQuery) || organizer.contains(_searchQuery);
      }

      return matchesStatus && matchesSearch;
    }).toList();

    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 50, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text("Tidak ada data.", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final ev = filteredEvents[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: SubmittedKerangka.adminEventCard(
            title: ev['title'] ?? "-",
            organizer: ev['organizer'] ?? "-",
            status: _capitalize(ev['status'] ?? "Pending"),

            // 👇 1. KABEL TOMBOL ACCEPT 👇
            onAccept: () async {
              final result = await _eventService.updateEventStatus(
                ev['id'],
                'approved',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result['message'])));
                if (result['success'] == true) {
                  _loadEvents(); // Muat ulang daftar setelah sukses
                }
              }
            },

            // 👇 2. KABEL TOMBOL REJECT 👇
            onReject: () async {
              final result = await _eventService.updateEventStatus(
                ev['id'],
                'rejected',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result['message'])));
                if (result['success'] == true) {
                  _loadEvents(); // Muat ulang daftar setelah sukses
                }
              }
            },

            // Tombol View Details
            onView: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RegistrationDetailsPage(eventId: ev['id']),
                ),
              );
            },

            // 👇 3. KABEL TOMBOL DELETE (DENGAN POP-UP KONFIRMASI) 👇
            onDelete: () async {
              // Munculkan Pop-Up peringatan dulu
              bool? confirm = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    "Hapus Event?",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: const Text(
                    "Event ini akan dihapus secara permanen dari database. Lanjutkan?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text(
                        "Batal",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                      ),
                      child: const Text(
                        "Hapus",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              // Jika user memilih "Hapus", jalankan API
              if (confirm == true) {
                final result = await _eventService.deleteEvent(ev['id']);
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(result['message'])));
                  if (result['success'] == true) {
                    _loadEvents(); // Muat ulang daftar setelah sukses
                  }
                }
              }
            },
          ),
        );
      },
    );
  }

  // Fungsi kecil untuk membuat huruf pertama besar (Pending, Approved, dll)
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
