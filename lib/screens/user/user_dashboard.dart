import 'package:flutter/material.dart';
import 'package:vhnsnc_indoor/screens/user/payment_history_screen.dart';

// Ensure these paths match your project structure exactly
import './../settings/settings.dart';
import './membership_card_screen.dart';
import './make_payment_screen.dart';
import './announcements_screen.dart';
import './profile_screen.dart';

// NOTE:
// - Light & Dark themes are defined
// - UI CURRENTLY USES LIGHT THEME ONLY (as requested)
// - Theme toggle is FUTURE FEATURE (not implemented)

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  // MOCK USER DATA (Replace with real auth/provider later)
  final Map<String, dynamic> user = const {
    'name': 'Mohammad Faseed',
    'membershipStatus': 'paid',
    'membershipExpiry': '2025-01-15'
  };

  // Helper function to navigate to a new screen
  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- DATA PREPARATION (Calculated once per build for performance) ---

    // 1. Logic Fix: Check for 'paid' status
    final String rawStatus = user['membershipStatus'] ?? 'unpaid';
    final bool isPaid = rawStatus.toLowerCase() == 'paid';

    // 2. Safe Date Parsing: Prevents "Signal 3" hangs on bad date strings
    final DateTime expiryDate = DateTime.tryParse(user['membershipExpiry'] ?? '') ?? DateTime.now();
    final String formattedExpiry = "${expiryDate.year}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.day.toString().padLeft(2, '0')}";

    // 3. Logic: Check if expiring within 30 days
    final int daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    final bool expiringSoon = isPaid && daysUntilExpiry <= 30 && daysUntilExpiry >= 0;

    return Scaffold(
      backgroundColor: LightTheme.background,
      body: SingleChildScrollView(
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
                          Text(user['name'], style: LightTheme.headingWhite),
                        ],
                      ),
                      IconButton(
                        onPressed: () => _navigateToScreen(context, const SettingsScreen()),
                        icon: const Icon(Icons.settings_outlined),
                        color: Colors.white,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white24,
                        ),
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
                                    color: isPaid ? Colors.green[100] : Colors.red[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isPaid ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: isPaid ? Colors.green[700] : Colors.red[700],
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
                    label: 'Make Payment',
                    color: Colors.green,
                    onTap: () => _navigateToScreen(context, const MakePaymentScreen()),
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
                  color: Colors.white, // Pure white background
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05), // Light, clean shadow
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