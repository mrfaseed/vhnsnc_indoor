import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

// Simple data model for Announcements
class Announcement {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'].toString(),
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['created_at']),
    );
  }
}

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAnnouncements();
  }

  Future<void> _fetchAnnouncements() async {
    try {
      final url = Uri.parse('${Config.baseUrl}/get_announcements.php');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final List<dynamic> list = data['data'];
          setState(() {
            _announcements = list.map((e) => Announcement.fromJson(e)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Failed to load: " + (data['message'] ?? "Unknown error");
            _isLoading = false;
          });
        }
      } else {
         setState(() {
            _errorMessage = "Server Error: ${response.statusCode}";
            _isLoading = false;
          });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network Error: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDE7), Colors.white], // yellow-50 to white
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              _buildAppBar(context),

              // Content Area
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                    : _errorMessage != null
                        ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                        : _announcements.isEmpty
                            ? _buildEmptyState()
                            : _buildAnnouncementsList(_announcements),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. App Bar Header
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Text(
            "Announcements",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // 2. Empty State (When no announcements)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "No announcements yet",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // 3. Scrollable List of Announcements
  Widget _buildAnnouncementsList(List<Announcement> announcements) {
    return RefreshIndicator(
      onRefresh: _fetchAnnouncements,
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final item = announcements[index];
          return _buildAnnouncementCard(item);
        },
      ),
    );
  }

  // 4. Individual Announcement Card
  Widget _buildAnnouncementCard(Announcement announcement) {
    // Format date: January 5, 2026
    String formattedDate = DateFormat('MMMM d, y').format(announcement.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.transparent), // Placeholder for hover effect
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Bell Icon with Gradient
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFB8C00), Color(0xFFFFB74D)], // orange-400 to orange-300
                  ),
                ),
                child: const Icon(Icons.notifications, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formattedDate,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            announcement.description,
            style: const TextStyle(color: Color(0xFF424242), height: 1.5),
          ),
        ],
      ),
    );
  }
}
