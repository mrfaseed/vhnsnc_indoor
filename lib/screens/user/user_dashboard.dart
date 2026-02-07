import 'package:flutter/material.dart';
import 'package:vhnsnc_indoor/screens/user/payment_history_screen.dart';

// Ensure these paths match your project structure exactly
import './../settings/settings.dart';
import '../../screens/login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart' as app_config;
import './membership_card_screen.dart';
import './make_payment_screen.dart';
import './announcements_screen.dart';
import './profile_screen.dart';

// NOTE:
// - Light & Dark themes are defined
// - UI CURRENTLY USES LIGHT THEME ONLY (as requested)
// - Theme toggle is FUTURE FEATURE (not implemented)

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  // State Variables
  bool _isLoading = true;
  String _userName = 'User';
  String _membershipStatus = 'unpaid';
  String _membershipExpiry = '';
  int _daysRemaining = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');
    final storedName = prefs.getString('user_name');

    if (storedName != null) {
      setState(() => _userName = storedName);
    }

    if (userId != null) {
      await _fetchUserDetails(userId);
    } else {
       // Handle case where user_id is missing (logout?)
       if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUserDetails(String userId) async {
    try {
      final response = await http.get(Uri.parse('${app_config.Config.baseUrl}/get_user_details.php?user_id=$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final userData = data['data'];
          if (mounted) {
            setState(() {
              _userName = userData['name'];
              _membershipStatus = userData['membership_status'];
              _membershipExpiry = userData['membership_expiry'] ?? '';
              _daysRemaining = userData['days_remaining'] ?? 0;
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    // Clear Session
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    // Navigate to Login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  // Helper function to navigate to a new screen
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    ).then((_) => _loadUserData()); // Refresh data when returning from other screens
  }

  @override
  Widget build(BuildContext context) {
    // Logic: Check status
    final bool isPaid = _membershipStatus.toLowerCase() == 'paid';
    final bool isExpired = _membershipStatus.toLowerCase() == 'expired';

    // Safe Date Parsing
    DateTime? expiryDate;
    String formattedExpiry = "N/A";
    if (_membershipExpiry.isNotEmpty) {
       expiryDate = DateTime.tryParse(_membershipExpiry);
       if(expiryDate != null) {
         formattedExpiry = "${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}";
       }
    }

    // Expiring Soon Logic
    final bool expiringSoon = isPaid && _daysRemaining <= 30 && _daysRemaining >= 0;

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
           if (context.mounted) _handleLogout();
        }
      },
      child: Scaffold(
      backgroundColor: LightTheme.background,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFFFC107), // warm golden yellow
                    Color(0xFFFFA000), // deeper amber
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Welcome Back,', style: LightTheme.subTextWhite),
                          const SizedBox(height: 4),
                          Text(_userName, style: LightTheme.headingWhite),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => _navigateToScreen(context, const SettingsScreen()),
                            icon: const Icon(Icons.settings_outlined),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white24,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                                        _handleLogout();
                                      },
                                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                                      child: const Text("Logout"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout),
                            color: Colors.white,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white24,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- MEMBERSHIP STATUS CARD ---
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1), // soft warm yellow
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 15,
                          offset: Offset(0, 8),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Membership Status', style: LightTheme.subText),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isPaid ? Colors.green[100] : (isExpired ? Colors.orange[100] : Colors.red[100]),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isPaid ? 'Active' : (isExpired ? 'Expired' : 'Inactive'),
                                    style: TextStyle(
                                      color: isPaid ? Colors.green[700] : (isExpired ? Colors.orange[800] : Colors.red[700]),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            CircleAvatar(
                              backgroundColor: isPaid ? Colors.green[50] : Colors.red[50],
                              child: Icon(
                                isPaid ? Icons.check_circle_outline : Icons.error_outline,
                                color: isPaid ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Expiry Date', style: LightTheme.subText),
                                const SizedBox(height: 4),
                                Text(formattedExpiry, style: LightTheme.bodyText),
                              ],
                            ),
                            if (expiringSoon)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Expiring Soon',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- QUICK ACTIONS GRID ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _ActionCard(
                    icon: Icons.badge_outlined,
                    label: 'Membership Card',
                    color: Colors.blue,
                    onTap: () => _navigateToScreen(context, const MembershipCardScreen()),
                  ),
                  _ActionCard(
                    icon: Icons.payments_outlined,
                    label: isPaid ? 'Already Paid' : 'Make Payment',
                    color: Colors.green,
                    onTap: () {
                         if (isPaid) {
                           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You are already an active member!")));
                         } else {
                           _navigateToScreen(context, const MakePaymentScreen());
                         }
                    },
                  ),
                  _ActionCard(
                    icon: Icons.campaign_outlined,
                    label: 'Announcements',
                    color: Colors.purple,
                    onTap: () => _navigateToScreen(context, const AnnouncementsScreen()),
                  ),
                  _ActionCard(
                    icon: Icons.person_outline,
                    label: 'Profile',
                    color: Colors.orange,
                    onTap: () => _navigateToScreen(context, const ProfileScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- PAYMENT HISTORY TILE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _navigateToScreen(context, const PaymentHistoryScreen()),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Color(0xFFFFF8E1),
                                child: Icon(Icons.history_rounded, color: Color(0xFFFFA000)),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payment History', style: LightTheme.bodyText),
                                  Text('View all transactions', style: LightTheme.subText),
                                ],
                              )
                            ],
                          ),
                          const Icon(Icons.chevron_right, color: Colors.grey)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      ),
    );
  }
}

// --- REUSABLE ACTION CARD COMPONENT ---

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, // Fix: Set white background here
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Subtle shadow
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: LightTheme.bodyText.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- THEME DEFINITIONS ---

class LightTheme {
  static const background = Color(0xFFF9FAFB);

  static const headingWhite = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const subTextWhite = TextStyle(
    color: Colors.white70,
    fontSize: 14,
  );

  static const bodyText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Color(0xFF111827),
  );

  static const subText = TextStyle(
    fontSize: 13,
    color: Color(0xFF6B7280),
  );
}

class DarkTheme {
  static const background = Color(0xFF0F172A);
}

