import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'user_details.dart';
import '../../config.dart';

class UserSearchDelegate extends SearchDelegate {
  
  @override
  String get searchFieldLabel => 'Search user by name...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    // Customizing the search bar to match the app theme
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Determine what to show when user hits "Enter"
    return _buildUserList(query);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Determine what to show while user types
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.black12),
            SizedBox(height: 16),
            Text("Type a name to search", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }
    return _buildUserList(query);
  }

  Widget _buildUserList(String query) {
    return FutureBuilder(
      future: _searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.amber));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final List<dynamic> users = snapshot.data as List<dynamic>;

        if (users.isEmpty) {
          return const Center(child: Text("No users found matching this name."));
        }

        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final user = users[index];
            final bool isPaid = user['membership_status'] == 'paid';
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.amber.shade100,
                child: Text(
                  user['name'][0].toUpperCase(),
                  style: TextStyle(color: Colors.amber.shade900, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(user['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user['email']),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPaid ? "Active" : "Inactive",
                  style: TextStyle(
                    color: isPaid ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                // Navigate to details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserDetailScreen(userId: user['id'].toString()),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Future<List<dynamic>> _searchUsers(String query) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/search_users.php?query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'];
        }
      }
      return [];
    } catch (e) {
      debugPrint("Search error: $e");
      return [];
    }
  }
}
