import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'user_details.dart'; // Import for navigation

// Simple Model to mirror your React User context
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String membershipStatus; // 'paid' or 'unpaid'
  // final DateTime membershipExpiry; // Logic for this would be complex from just created_at

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membershipStatus,
    // required this.membershipExpiry,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      membershipStatus: json['membership_status'] ?? 'unpaid',
      // membershipExpiry: DateTime.now(), // Placeholder
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

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/get_users.php'));
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters Row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) => setState(() => _searchTerm = value),
                    decoration: InputDecoration(
                      hintText: "Search by name or email...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _filterStatus,
                  items: const [
                    DropdownMenuItem(value: 'all', child: Text('All')),
                    DropdownMenuItem(value: 'paid', child: Text('Paid')),
                    DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
                  ],
                  onChanged: (value) => setState(() => _filterStatus = value!),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // User Table (DataTable)
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.amber))
                  : Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _filteredUsers.map((user) {
                        return DataRow(cells: [
                          DataCell(Text(user.name)),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: user.membershipStatus == 'paid' ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user.membershipStatus == 'paid' ? 'Active' : 'Inactive',
                              style: TextStyle(color: user.membershipStatus == 'paid' ? Colors.green[800] : Colors.red[800]),
                            ),
                          )),
                          DataCell(
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserDetailScreen(userId: user.id),
                                  ),
                                );
                              },
                              child: const Text('View Details', style: TextStyle(color: Colors.blue)),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('Showing ${_filteredUsers.length} of ${_allUsers.length} users'),
            ),
          ],
        ),
      ),
    );
  }
}