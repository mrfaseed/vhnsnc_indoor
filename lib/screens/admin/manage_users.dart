import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../../config.dart' as app_config;
import '../../widgets/aurora_background.dart';
import 'user_details.dart'; // Import for navigation

// Simple Model
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String membershipStatus; // 'paid' or 'unpaid'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membershipStatus,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      membershipStatus: json['membership_status'] ?? 'unpaid',
    );
  }
}

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  List<User> _allUsers = [];
  bool _isLoading = true;
  String _searchTerm = '';
  String _filterStatus = 'all';

  // Gold Theme Colors
  static const Color _primaryGold = Color(0xFFFFC107);
  static const Color _darkGold = Color(0xFFFF8F00);
  static const Color _cardSurface = Colors.white;
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF757575);

  static const LinearGradient _backgroundGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // Gold
      Color(0xFFF8C550), // Amber
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${app_config.Config.baseUrl}/get_users.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _allUsers = (data['data'] as List).map((json) => User.fromJson(json)).toList();
          });
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching users: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Filtering Logic
  List<User> get _filteredUsers {
    return _allUsers.where((user) {
      final matchesSearch = user.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchTerm.toLowerCase());
      final matchesFilter = _filterStatus == 'all' || user.membershipStatus == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        body: AuroraBackground(
          colors: _backgroundGradient.colors,
          child: SafeArea(
            child: Column(
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: _textPrimary),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Manage Users",
                        style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: _textPrimary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // --- Search & Filter Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          ),
                          child: TextField(
                            onChanged: (value) => setState(() => _searchTerm = value),
                            decoration: InputDecoration(
                              hintText: "Search name or email...",
                              prefixIcon: const Icon(Icons.search, color: _textSecondary),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _filterStatus,
                            icon: const Icon(Icons.filter_list, color: _primaryGold),
                            underline: Container(),
                            items: const [
                              DropdownMenuItem(value: 'all', child: Text('All')),
                              DropdownMenuItem(value: 'paid', child: Text('Paid')),
                              DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                            ],
                            onChanged: (value) => setState(() => _filterStatus = value!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // --- Users List ---
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: _primaryGold))
                      : _filteredUsers.isEmpty 
                        ? Center(child: Text("No users found", style: TextStyle(color: _textSecondary)))
                        : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            final isPaid = user.membershipStatus == 'paid';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: _cardSurface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isPaid ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                     Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => UserDetailScreen(userId: user.id),
                                      ),
                                    ).then((_) => _fetchUsers()); // Refresh on return
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        // Avatar
                                        Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: isPaid ? Colors.green[50] : Colors.red[50],
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: isPaid ? Colors.green[700] : Colors.red[700],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: _textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                user.email,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: _textSecondary,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Chip
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isPaid ? Colors.green : Colors.red,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                isPaid ? 'Active' : 'Unpaid',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                
                // Footer Stats
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    'Showing ${_filteredUsers.length} of ${_allUsers.length} users',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}