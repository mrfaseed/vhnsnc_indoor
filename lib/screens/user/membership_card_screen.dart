import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config.dart' as app_config;

// User model to mimic your AuthContext
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime memberSince;
  final DateTime membershipExpiry;
  final String membershipStatus;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.memberSince,
    required this.membershipExpiry,
    required this.membershipStatus,
  });
}

class MembershipCardScreen extends StatefulWidget {
  const MembershipCardScreen({super.key});

  @override
  State<MembershipCardScreen> createState() => _MembershipCardScreenState();
}

class _MembershipCardScreenState extends State<MembershipCardScreen> {
  UserProfile? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await http.get(Uri.parse('${app_config.Config.baseUrl}/get_user_details.php?user_id=$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final userData = data['data'];

          // Safe Date Parsing
          DateTime memberSince = DateTime.tryParse(userData['created_at'] ?? '') ?? DateTime.now();
          DateTime membershipExpiry = DateTime.tryParse(userData['membership_expiry'] ?? '') ?? DateTime.now();

          setState(() {
            _user = UserProfile(
              id: userData['id'].toString(),
              name: userData['name'] ?? 'Unknown',
              email: userData['email'] ?? '',
              phone: userData['phone'] ?? '',
              memberSince: memberSince,
              membershipExpiry: membershipExpiry,
              membershipStatus: userData['membership_status'] ?? 'unpaid',
            );
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching membership card: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDE7), Colors.white],
          ),
        ),
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.amber))
            : _user == null 
              ? const Center(child: Text("Could not load details"))
              : SingleChildScrollView(
            child: Column(
              children: [
                _buildAppBar(context),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      _buildMembershipCard(_user!),
                      const SizedBox(height: 24),
                      _buildQRCodeSection(_user!),
                      const SizedBox(height: 24),
                      _buildMemberDetails(_user!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 1. Custom Header
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const Text("Membership Card", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 2. The Golden Membership Card (The complex part)
  Widget _buildMembershipCard(UserProfile user) {
    bool isPaid = user.membershipStatus == 'paid';

    return Container(
      width: double.infinity,
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFD600), Color(0xFFFFE57F), Color(0xFFFFF176)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.yellow.shade700.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Decorative Court Lines (Absolute positioning)
          Opacity(
            opacity: 0.1,
            child: Stack(
              children: [
                Center(child: Container(width: 2, color: Colors.brown)),
                Center(child: Container(height: 2, color: Colors.brown)),
              ],
            ),
          ),

          // Shuttlecock Decoration
          Positioned(
            top: 20,
            right: 20,
            child: Opacity(
              opacity: 0.2,
              child: Column(
                children: [
                  Container(width: 12, height: 12, decoration: const BoxDecoration(color: Colors.brown, shape: BoxShape.circle)),
                  const Icon(Icons.keyboard_arrow_up, size: 30, color: Colors.brown),
                ],
              ),
            ),
          ),

          // Card Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.flash_on, color: Colors.amber),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Member Since", style: TextStyle(color: Color(0xFF5D4037), fontSize: 12)),
                            Text("${user.memberSince.year}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(isPaid ? "Active" : "Inactive", style: const TextStyle(color: Colors.white, fontSize: 12)),
                    )
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: Center(child: Text(user.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(user.email, style: TextStyle(color: Colors.grey.shade800, fontSize: 13)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.black12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _cardSmallDetail("Member ID", user.id.toUpperCase()),
                    _cardSmallDetail("Expiry Date", _formatDate(user.membershipExpiry)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardSmallDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF5D4037), fontSize: 10)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }

  // 3. QR Code Section
  Widget _buildQRCodeSection(UserProfile user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.yellow.shade200, width: 2),
      ),
      child: Column(
        children: [
          const Text("Scan to verify membership", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFFDE7), Colors.white]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.yellow.shade100),
            ),
            child: QrImageView(
              data: user.id,
              version: QrVersions.auto,
              size: 200.0,
              gapless: false,
              foregroundColor: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Text("QR Code: ${user.id.toUpperCase()}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  // Helper for date formatting
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  // 4. Details List
  Widget _buildMemberDetails(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.yellow.shade200, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Member Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _detailRow("Full Name", user.name),
          _detailRow("Email", user.email),
          _detailRow("Phone", user.phone),
          _detailRow("Member Since", _formatDate(user.memberSince), isLast: true),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.yellow.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}