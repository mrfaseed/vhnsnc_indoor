import 'package:flutter/material.dart';
import 'manage_users.dart';
import 'payment_overview.dart';
import 'create_announcement.dart';
import 'user_details.dart';
import '../create_account.dart';
import 'manage_announcements.dart';
import 'admin_create_user.dart';
import 'admin_qr_scan.dart';
import 'user_search_delegate.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  // Theme Colors
  static const Color _primaryYellow = Color(0xFFFFC107);
  static const Color _lightYellow = Color(0xFFFFF8E1);
  static const Color _background = Color(0xFFFBFBFB);
  static const Color _textPrimary = Color(0xFF212121);
  static const Color _textSecondary = Color(0xFF616161);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Logout"),
            content: const Text("Are you sure you want to logout?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Logout"),
              ),
            ],
          ),
        );
        if (shouldPop ?? false) {
          if (context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _primaryYellow,
        elevation: 2,
        iconTheme: const IconThemeData(color: _textPrimary),
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(color: _textPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Exit screen
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.black87),
          ),
        ],
      ),

      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Overview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary),
            ),
            const SizedBox(height: 16),

            // 1. Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard("Total Users", "150", Icons.people_outline),
                _buildStatCard("Paid Members", "120", Icons.verified_user_outlined),
                _buildStatCard("Pending", "30", Icons.hourglass_empty_rounded),
                _buildStatCard("Revenue", "₹45,000", Icons.account_balance_wallet_outlined),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary),
            ),
            const SizedBox(height: 16),

            // 2. Quick Actions Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(
                  Icons.manage_accounts,
                  "Manage Users",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageUsers()),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.payments,
                  "Transactions",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaymentsOverview()),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.campaign,
                  "Create Announcements",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateAnnouncement()),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.edit_note,
                  "Manage Announcements",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ManageAnnouncements()),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.search,
                  "Search User",
                  onTap: () {
                    showSearch(
                      context: context,
                      delegate: UserSearchDelegate(),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.person_add,
                  "Create User",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminCreateUser()),
                    );
                  },
                ),
                _buildActionCard(
                  Icons.qr_code_scanner,
                  "Scan QR",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AdminQRScanScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text(
              "Recent Payments",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _textPrimary),
            ),
            const SizedBox(height: 12),

            // 3. Recent Payments List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: _lightYellow,
                      child: Icon(Icons.person, color: Colors.orange),
                    ),
                    title: Text("Transaction #${1024 + index}",
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text("Jan 06, 2026 • 11:59 AM"),
                    trailing: const Text(
                      "₹500",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      ),
    );
  }

  // Helper for Stats Cards (Unified Yellow Style)
  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.orange, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: _textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      color: _textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                  )
              ),
            ],
          )
        ],
      ),
    );
  }

  // Helper for Quick Action Cards
  Widget _buildActionCard(IconData icon, String title, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: _lightYellow.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _primaryYellow.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.brown, size: 26),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.brown
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}