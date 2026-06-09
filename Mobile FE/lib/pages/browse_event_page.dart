import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../kerangka/home_kerangka.dart';
import '../services/event_service.dart';

class BrowseEventPage extends StatefulWidget {
  const BrowseEventPage({super.key});

  @override
  State<BrowseEventPage> createState() => _BrowseEventPageState();
}

class _BrowseEventPageState extends State<BrowseEventPage> {
  final ApiEventService _eventService = ApiEventService();

  // State manajemen data
  List<dynamic> _allEvents = [];
  List<dynamic> _filteredEvents = [];
  List<dynamic> _recommendedEvents = [];
  bool _isPersonalized = false;
  bool _isLoading = true;
  String _errorMessage = '';

  // State filter pencarian & kategori
  final List<String> _categories = [
    'All',
    'Seminar',
    'Workshop',
    'Competition',
    'Training',
  ];
  String _selectedCategory = 'All';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBrowseData();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --- FUNGSI AMBIL DATA DARI API LARAVEL ---
  Future<void> _fetchBrowseData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Menggunakan fetchHomeData karena sudah merangkum seluruh event approved di database
      final response = await _eventService.fetchHomeData();

      if (mounted) {
        setState(() {
          if (response['success'] == true) {
            _allEvents = response['all_events'] ?? [];

            // 👇 Tangkap datanya dari API 👇
            _recommendedEvents = response['recommended'] ?? [];
            _isPersonalized = response['is_personalized'] ?? false;

            _applyFilterAndSearch();
          } else {
            _errorMessage = response['message'] ?? "Gagal memuat data event.";
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Terjadi kesalahan koneksi: $e";
          _isLoading = false;
        });
      }
    }
  }

  // --- ENGINE FILTER & SEARCH (REAL-TIME DI SISI CLIENT) ---
  void _applyFilterAndSearch() {
    setState(() {
      _filteredEvents = _allEvents.where((ev) {
        // 1. Logika Penyaringan Kategori
        bool matchesCategory = true;
        if (_selectedCategory != 'All') {
          final evCategory = (ev['category'] ?? '').toString().toLowerCase();
          matchesCategory = evCategory == _selectedCategory.toLowerCase();
        }

        // 2. Logika Penyaringan Kata Kunci Search Bar
        bool matchesSearch = true;
        if (_searchCtrl.text.isNotEmpty) {
          final query = _searchCtrl.text.toLowerCase();
          final title = (ev['title'] ?? '').toString().toLowerCase();
          final location = (ev['location'] ?? '').toString().toLowerCase();

          matchesSearch = title.contains(query) || location.contains(query);
        }

        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryPink),
              )
            : _errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.redAccent,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchBrowseData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.darkBlue,
                        ),
                        child: const Text(
                          "Coba Lagi",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                color: AppTheme.primaryPink,
                onRefresh: _fetchBrowseData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- 1. JUDUL & SUB-JUDUL ---
                      const Text(
                        "Browse Events",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Discover exciting events at Telkom University",
                        style: TextStyle(fontSize: 14, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 24),

                      // --- 2. SEARCH BAR (KOLOM PENCARIAN DENGAN REAKSI OTOMATIS) ---
                      TextField(
                        controller: _searchCtrl,
                        onChanged: (value) =>
                            _applyFilterAndSearch(), // Saring otomatis setiap ketikan huruf
                        decoration: InputDecoration(
                          hintText: "Cari judul atau lokasi event...",
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                          suffixIcon: _searchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _applyFilterAndSearch();
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 16,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppTheme.primaryPink,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      if (_searchCtrl.text.isEmpty &&
                          _selectedCategory == 'All' &&
                          _recommendedEvents.isNotEmpty) ...[
                        Container(
                          // 1. Padding & Margin biar konten ga nempel tembok
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.all(
                            16,
                          ), // Ruang dalam kotak
                          // 2. Dekorasi Kotak (Warna Latar & Lengkungan)
                          decoration: BoxDecoration(
                            // OPSI A (Merah Sangat Muda/Pink Soft khas Univent) - REKOMENDASI
                            color: AppTheme.primaryPink.withOpacity(0.08),

                            // OPSI B (Kalau bos maksa mau nuansa Merah, pakai yang shade muda)
                            // color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(
                              24,
                            ), // Sudut melengkung
                            border: Border.all(
                              color: AppTheme.primaryPink.withOpacity(0.2),
                            ), // Border tipis
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // A. Judul Rak (Kode Lama bos dimasukkan ke sini)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.auto_awesome,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _isPersonalized
                                        ? "Spesial Buat Kamu"
                                        : "Lagi Trending Nih 🔥",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.darkBlue,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // B. Rak Event Horizontal (SizedBox Lama bos, pastikan heightnya 380 ya!)
                              SizedBox(
                                height: 380, // Sesuaikan tinggi biar kartu muat
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: _recommendedEvents.length,
                                  itemBuilder: (context, index) {
                                    final ev = _recommendedEvents[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                      ),
                                      child: SizedBox(
                                        width: 240,
                                        child: HomeKerangka.eventCard(
                                          context: context,
                                          eventId: ev['id'],
                                          title: ev['title'] ?? 'Tanpa Judul',
                                          organizer: ev['organizer'] ?? '-',
                                          date: ev['date'] ?? '-',
                                          location: ev['location'] ?? '-',
                                          posterPath: ev['poster'],
                                          isRecommended: true,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // --- 3. KATEGORI (GESER HORIZONTAL) ---
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categories.map((category) {
                            bool isActive = _selectedCategory == category;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategory = category;
                                });
                                _applyFilterAndSearch(); // Saring otomatis saat ganti pil kategori
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppTheme.primaryPink
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.blueGrey,
                                    fontWeight: isActive
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- 4. LIST EVENT HASIL FILTER ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory == 'All'
                                ? "Semua Event Berjalan"
                                : "Kategori: $_selectedCategory",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkBlue,
                            ),
                          ),
                          Text(
                            "${_filteredEvents.length} ditemukan",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_filteredEvents.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.search_off_outlined,
                                  size: 60,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Tidak ada event yang cocok dengan kriteria pencarianmu.",
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(), // Karena sudah dibungkus SingleChildScrollView di atas
                          itemCount: _filteredEvents.length,
                          itemBuilder: (context, index) {
                            final ev = _filteredEvents[index];
                            return HomeKerangka.eventCard(
                              context: context,
                              eventId: ev['id'],
                              title: ev['title'] ?? 'Tanpa Judul',
                              organizer: ev['organizer'] ?? '-',
                              date: ev['date'] ?? '-',
                              location: ev['location'] ?? '-',
                              posterPath: ev['poster'],
                              isRecommended:
                                  index ==
                                  0, // Kartu teratas otomatis ditandai rekomendasi pencarian
                            );
                          },
                        ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
