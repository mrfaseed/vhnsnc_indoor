import 'package:flutter/material.dart';

// Simple Model to mirror your React User context
class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String membershipStatus; // 'paid' or 'unpaid'
  final DateTime membershipExpiry;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membershipStatus,
    required this.membershipExpiry,
  });
}

class ManageUsers extends StatefulWidget {
  const ManageUsers({super.key});

  @override
  State<ManageUsers> createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {
  final List<User> _allUsers = [
    User(id: '1', name: 'John Doe', email: 'john@example.com', phone: '123456789', membershipStatus: 'paid', membershipExpiry: DateTime.now().add(const Duration(days: 30))),
    User(id: '2', name: 'Jane Smith', email: 'jane@example.com', phone: '987654321', membershipStatus: 'unpaid', membershipExpiry: DateTime.now()),
  ];

  String _searchTerm = '';
  String _filterStatus = 'all';

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
        // Yellow Theme applied here
        backgroundColor: Colors.amber,
        foregroundColor: Colors.black,
        elevation: 1,
        title: const Text('Manage Users', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // HOW TO SET ONCLICK (Navigation)
            Navigator.pop(context);
          },
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
              child: Container(
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
                              // HOW TO SET ONCLICK (Action Button)
                              onPressed: () {
                                print("Navigating to user: ${user.id}");
                                // Navigate to details page logic here
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