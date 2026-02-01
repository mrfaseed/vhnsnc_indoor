import 'package:flutter/material.dart';

// Simple data model to mimic your "useAuth" user object
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final DateTime memberSince;
  final DateTime membershipExpiry;
  final String membershipStatus; // 'paid' or 'unpaid'

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

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data (In a real app, you'd get this from your Auth Provider)
    final user = UserProfile(
      id: "usr-9921",
      name: "Mohammad Faseed",
      email: "faseedmohamed6@gmail.com",
      phone: "+91 98765 43210",
      memberSince: DateTime(2023, 5, 15),
      membershipExpiry: DateTime(2026, 5, 15),
      membershipStatus: 'paid',
    );

    return Scaffold(
      // The background gradient
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Custom Header (AppBar replacement)
                _buildHeader(context),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Profile Header Card
                      _buildProfileHeaderCard(user),
                      const SizedBox(height: 24),

                      // Personal Information Card
                      _buildPersonalInfoCard(user),
                      const SizedBox(height: 24),

                      // Membership Details Card
                      _buildMembershipCard(user),
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

  // 1. Top Navigation Bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2))
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
            "Profile",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121)),
          ),
        ],
      ),
    );
  }

  // 2. Main Profile Avatar Card
  Widget _buildProfileHeaderCard(UserProfile user) {
    bool isPaid = user.membershipStatus == 'paid';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.yellow.shade200, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Colors.yellow, Colors.orange]),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                    color: Colors.yellow.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Center(
              child: Text(
                user.name[0],
                style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          Text(user.email, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPaid ? 'Active Member' : 'Inactive Member',
              style: TextStyle(
                color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 3. Personal Info List
  Widget _buildPersonalInfoCard(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.yellow.shade200, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Personal Information",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit, size: 16, color: Colors.orange),
                label: const Text("Edit", style: TextStyle(color: Colors.orange)),
              )
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.email_outlined, "Email", user.email),
          _infoRow(Icons.phone_outlined, "Phone Number", user.phone),
          _infoRow(Icons.calendar_today_outlined, "Member Since",
              "${user.memberSince.day} May, ${user.memberSince.year}"),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          )
        ],
      ),
    );
  }

  // 4. Membership Key-Value Table
  Widget _buildMembershipCard(UserProfile user) {
    bool isPaid = user.membershipStatus == 'paid';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.yellow.shade200, width: 2),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Membership Details",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          _dataRow("Member ID", user.id.toUpperCase()),
          const Divider(color: Color(0xFFFFF9C4)),
          _dataRow("Status", isPaid ? "Active" : "Inactive", isStatus: true, isPaid: isPaid),
          const Divider(color: Color(0xFFFFF9C4)),
          _dataRow("Expiry Date", "15 May, 2026"),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value, {bool isStatus = false, bool isPaid = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isPaid ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(value,
                  style: TextStyle(
                      color: isPaid ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.bold)),
            )
          else
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }
}