import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config.dart' as app_config;
import '../../widgets/aurora_background.dart';

class ManageAnnouncements extends StatefulWidget {
  const ManageAnnouncements({super.key});

  @override
  State<ManageAnnouncements> createState() => _ManageAnnouncementsState();
}

class _ManageAnnouncementsState extends State<ManageAnnouncements> {
  List<dynamic> _announcements = [];
  bool _isLoading = true;

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
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(Uri.parse('${app_config.Config.baseUrl}/get_announcements.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _announcements = data['data'];
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching announcements: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAnnouncement(String id) async {
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Announcement"),
        content: const Text("Are you sure you want to delete this announcement? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.post(
          Uri.parse('${app_config.Config.baseUrl}/delete_announcement.php'),
          body: json.encode({'id': id}),
        );
        final data = json.decode(response.body);
        if (data['success']) {
          _fetchAnnouncements();
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Announcement deleted")));
        } else {
             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  Future<void> _editAnnouncement(Map<String, dynamic> announcement) async {
    final titleController = TextEditingController(text: announcement['title']);
    final descController = TextEditingController(text: announcement['description']);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Announcement",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _textPrimary),
                ),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // Show Loading
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(
                      child: CircularProgressIndicator(color: _primaryGold),
                    ),
                  );

                  try {
                    final response = await http.post(
                      Uri.parse('${app_config.Config.baseUrl}/edit_announcement.php'),
                      body: json.encode({
                        'id': announcement['id'],
                        'title': titleController.text,
                        'description': descController.text,
                      }),
                    );

                    // Close Loading
                    if (context.mounted) Navigator.pop(context);

                    if (response.statusCode == 200) {
                      try {
                        final data = json.decode(response.body);
                        if (data['success']) {
                          if (context.mounted) {
                            Navigator.pop(context); // Close Bottom Sheet
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Announcement updated successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                          _fetchAnnouncements();
                        } else {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(data['message'] ?? "Unknown error"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                         // JSON Parse Error (HTML response)
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Server Error: Invalid response format. Please check if PHP file exists on server."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } 
                      }
                    } else {
                       if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Server Error: ${response.statusCode}"), backgroundColor: Colors.red),
                          );
                       }
                    }
                  } catch (e) {
                    if (context.mounted) Navigator.pop(context); // Close Loading
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGold,
                  foregroundColor: _textPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: AuroraBackground(
          colors: _backgroundGradient.colors,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                        "Manage Announcements",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textPrimary),
                      ),
                    ],
                  ),
                ),
                
                // List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: _primaryGold))
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: _announcements.length,
                          itemBuilder: (context, index) {
                            final item = _announcements[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: _cardSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _primaryGold.withOpacity(0.3)),
                                boxShadow: [
                                  BoxShadow(
                                    color: _darkGold.withOpacity(0.08),
                                    blurRadius: 16,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item['title'],
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _primaryGold.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            item['created_at'].toString().split(' ')[0], // Date only
                                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _darkGold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      item['description'],
                                      style: const TextStyle(fontSize: 14, color: _textSecondary, height: 1.5),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 20),
                                    Divider(color: Colors.grey.withOpacity(0.2)),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => _editAnnouncement(item),
                                          icon: const Icon(Icons.edit_outlined, size: 20),
                                          label: const Text("Edit"),
                                          style: TextButton.styleFrom(foregroundColor: Colors.blue.shade700),
                                        ),
                                        const SizedBox(width: 8),
                                        TextButton.icon(
                                          onPressed: () => _deleteAnnouncement(item['id']),
                                          icon: const Icon(Icons.delete_outline, size: 20),
                                          label: const Text("Delete"),
                                          style: TextButton.styleFrom(foregroundColor: Colors.red.shade700),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
