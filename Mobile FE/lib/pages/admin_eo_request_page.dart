import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/admin_service.dart';

class AdminEoRequestPage extends StatefulWidget {
  const AdminEoRequestPage({super.key});

  @override
  State<AdminEoRequestPage> createState() => _AdminEoRequestPageState();
}

class _AdminEoRequestPageState extends State<AdminEoRequestPage> {
  List<dynamic> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);
    final result = await ApiAdminService.getPendingRequests();
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          _requests = result['data'] ?? [];
        }
        _isLoading = false;
      });
    }
  }

  void _handleAction(int id, bool isApprove) async {
    // Munculkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryPink),
      ),
    );

    final result = isApprove
        ? await ApiAdminService.approveEo(id)
        : await ApiAdminService.rejectEo(id);

    if (mounted) {
      Navigator.pop(context); // Tutup loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      if (result['success'] == true) {
        _fetchRequests(); // Refresh daftar jika sukses
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      appBar: AppBar(
        title: const Text(
          "Persetujuan Akun EO",
          style: TextStyle(
            color: AppTheme.darkBlue,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.darkBlue),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPink),
            )
          : _requests.isEmpty
          ? const Center(
              child: Text(
                "Tidak ada pengajuan EO saat ini.",
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              color: AppTheme.primaryPink,
              onRefresh: _fetchRequests,
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final user = _requests[index];
                  return _buildRequestCard(user);
                },
              ),
            ),
    );
  }

  Widget _buildRequestCard(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                user['eo_org_type'] ?? '-',
                style: const TextStyle(
                  color: AppTheme.primaryPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                "User: ${user['name']}",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user['eo_org_name'] ?? 'Organisasi Tidak Diketahui',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.darkBlue,
            ),
          ),
          const SizedBox(height: 12),
          _detailRow(Icons.person, "PIC", user['eo_pic_name']),
          const SizedBox(height: 4),
          _detailRow(Icons.phone, "WhatsApp", user['eo_phone']),
          if (user['eo_instagram'] != null) ...[
            const SizedBox(height: 4),
            _detailRow(Icons.link, "Media", user['eo_instagram']),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleAction(user['id'], false),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Tolak",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleAction(user['id'], true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Setujui",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          "$label: ",
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        Expanded(
          child: Text(
            value ?? '-',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.darkBlue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
