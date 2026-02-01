import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_screen.dart';

// SETTINGS SCREEN
// - Refined Premium UI with rigid alignment and improved symmetry
// - Fixed padding and standardized component heights

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;

  // Professional Palette
  static const Color goldAccent = Color(0xFFC5A028); // Deeper, more professional gold
  static const Color primaryText = Color(0xFF1A1C1E);
  static const Color secondaryText = Color(0xFF6C757D);
  static const Color surfaceBg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5, // Thin professional hairline stroke
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PREFERENCES SECTION
            const SectionTitle('PREFERENCES'),
            CardContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const IconCircle(
                      icon: Icons.nights_stay_rounded,
                      bg: Color(0xFFFFF9E6),
                      color: goldAccent,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dark Mode', style: ItemTitle()),
                          Text('Personalize your view', style: ItemSubtitle()),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8, // Make the switch more elegant/smaller
                      child: Switch(
                        activeColor: goldAccent,
                        value: darkMode,
                        onChanged: (v) => setState(() => darkMode = v),
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // SUPPORT SECTION
            const SectionTitle('SUPPORT'),
            CardContainer(
              child: Column(
                children: [
                  SettingsTile(
                    icon: Icons.auto_awesome_rounded,
                    iconBg: Color(0xFFF0F7FF),
                    iconColor: Color(0xFF0061FF),
                    title: 'Contact Support',
                    subtitle: '24/7 Premium Assistance',
                    onTap: () {},
                  ),
                  const Divider(height: 1, indent: 70, endIndent: 20, thickness: 0.8),
                  SettingsTile(
                    icon: Icons.info_outline_rounded,
                    iconBg: Color(0xFFF2F4F7),
                    iconColor: secondaryText,
                    title: 'About App',
                    subtitle: 'Version 1.0.0 (Gold)',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ACCOUNT SECTION
            const SectionTitle('ACCOUNT'),
            CardContainer(
              child: SettingsTile(
                icon: Icons.logout_rounded,
                iconBg: Color(0xFFFFF2F2),
                iconColor: Color(0xFFDC3545),
                title: 'Logout',
                subtitle: 'Securely end session',
                titleColor: Color(0xFFDC3545),
                onTap: () => _showLogoutDialog(context),
              ),
            ),

            const SizedBox(height: 60),

            // FOOTER
            Center(
              child: Column(
                children: [
                  Container(height: 1, width: 40, color: Colors.grey.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    "VHNSNC INDOOR",
                    style: TextStyle(
                      fontSize: 11,
                      letterSpacing: 5,
                      fontWeight: FontWeight.w900,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Are you sure you want to exit ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: secondaryText))),
          TextButton(
              onPressed: () async {
                // Delete Token
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('jwt_token');

                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
              child: const Text('Logout', style: TextStyle(color: Color(0xFFDC3545), fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }
}

// ----------------- REUSABLE WIDGETS -----------------

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFADB5BD),
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
          fontSize: 11,
        ),
      ),
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            IconCircle(icon: icon, bg: iconBg, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: ItemTitle(color: titleColor)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: ItemSubtitle()),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 22),
          ],
        ),
      ),
    );
  }
}

class IconCircle extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const IconCircle({super.key, required this.icon, required this.bg, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class ItemTitle extends TextStyle {
  const ItemTitle({Color? color})
      : super(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: color ?? const Color(0xFF1A1C1E),
  );
}

class ItemSubtitle extends TextStyle {
  ItemSubtitle() : super(fontSize: 12, color: const Color(0xFF6C757D), fontWeight: FontWeight.w400);
}