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
  List<dynamic> _activeAnnouncements = [];
  List<dynamic> _upcomingAnnouncements = [];
  List<dynamic> _oldAnnouncements = [];
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
      final response = await http.get(Uri.parse('${app_config.Config.baseUrl}/get_all_announcements.php'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final allAnnouncements = data['data'] as List;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          final active = [];
          final upcoming = [];
          final old = [];

          for (var item in allAnnouncements) {
             DateTime? startDate;
             if (item['start_date'] != null && item['start_date'] != "") {
               startDate = DateTime.parse(item['start_date']);
             }

            DateTime? endDate;
            if (item['end_date'] != null && item['end_date'] != "") {
               endDate = DateTime.parse(item['end_date']);
            }
            
            bool isUpcoming = false;
            // Check if upcoming (Start Date is strictly in the future)
            if (startDate != null && startDate.isAfter(today)) {
              isUpcoming = true;
            }

            bool isExpired = false;
            // Check if expired (Today is strictly after End Date)
            if (endDate != null && today.isAfter(endDate)) {
               isExpired = true;
            }

            if (isExpired) {
              old.add(item);
            } else if (isUpcoming) {
              upcoming.add(item);
            } else {
              active.add(item);
            }
          }

          setState(() {
            _activeAnnouncements = active;
            _upcomingAnnouncements = upcoming;
            _oldAnnouncements = old;
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
    
    DateTime? startDate = announcement['start_date'] != null ? DateTime.parse(announcement['start_date']) : null;
    DateTime? endDate = announcement['end_date'] != null ? DateTime.parse(announcement['end_date']) : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          
          Future<void> selectDate(bool isStart) async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2025),
              lastDate: DateTime(2030),
              builder: (context, child) => Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(primary: _darkGold, onPrimary: Colors.white),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              setModalState(() {
                if (isStart) startDate = picked; else endDate = picked;
              });
            }
          }

          return Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
              
              // Dates
               Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectDate(true),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Start Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(startDate != null ? startDate.toString().split(' ')[0] : "None", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => selectDate(false),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("End Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(endDate != null ? endDate.toString().split(' ')[0] : "None", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: descController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
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
                          'start_date': startDate?.toString().split(' ')[0],
                          'end_date': endDate?.toString().split(' ')[0],
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
                                content: Text("Server Error: Invalid response format."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } 
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
        );
        }
      ),
    );
  }

  Widget _buildList(List<dynamic> items, String title) {
    if (items.isEmpty && title == "Active Announcements") {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(child: Text("No active announcements")),
        ),
      );
    }
    if (items.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: title.contains("Old") ? Colors.grey : _textPrimary
                ),
              ),
            );
          }
          final item = items[index - 1];
          final isOld = title.contains("Old");
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: isOld ? Colors.grey[100] : _cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isOld ? Colors.grey[300]! : _primaryGold.withOpacity(0.3)),
              boxShadow: isOld ? [] : [
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
                          style: TextStyle(
                            fontSize: 18, 
                            fontWeight: FontWeight.bold, 
                            color: isOld ? Colors.grey[700] : _textPrimary
                          ),
                        ),
                      ),
                      if (!isOld)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _primaryGold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Active",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _darkGold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (item['start_date'] != null || item['end_date'] != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "${item['start_date'] ?? 'Now'} - ${item['end_date'] ?? 'Forever'}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
                      ),
                    ),
                  
                  Text(
                    item['description'],
                    style: TextStyle(fontSize: 14, color: isOld ? Colors.grey[600] : _textSecondary, height: 1.5),
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
        childCount: items.length + 1, // +1 for Header
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
                      : CustomScrollView(
                          slivers: [
                            _buildList(_activeAnnouncements, "Active Announcements"),
                            _buildList(_upcomingAnnouncements, "Upcoming Announcements"),
                            _buildList(_oldAnnouncements, "Old Announcements"),
                            const SliverToBoxAdapter(child: SizedBox(height: 40)),
                          ],
                        ),
                ),
              ],
            ),
          ),
      ),
    );
  }
}
