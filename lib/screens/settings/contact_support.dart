import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  // Theme Constants
  static const Color goldAccent = Color(0xFFC5A028);
  static const Color goldLight = Color(0xFFFFF9E6);
  static const Color primaryText = Color(0xFF1A1C1E);
  static const Color secondaryText = Color(0xFF6C757D);
  static const Color surfaceBg = Color(0xFFF8F9FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: primaryText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'CONTACT SUPPORT',
          style: TextStyle(
            color: primaryText,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // Header Illustration / Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: goldLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.support_agent_rounded,
                size: 64,
                color: goldAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "How can we help you?",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Our dedicated support team is available 24/7 to assist you with any inquiries.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: secondaryText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),

            // Contact Options
            _buildSupportOption(
              context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "Get a response within 24 hours",
              actionText: "support@vhnsnc.edu.in", // Placeholder
              onTap: () => _launchEmail(),
            ),
            const SizedBox(height: 16),
            _buildSupportOption(
              context,
              icon: Icons.phone_outlined,
              title: "Call Us",
              subtitle: "Mon-Fri from 9am to 6pm",
              actionText: "+91 1234567890", // Placeholder
              onTap: () => _launchPhone(),
            ),


            
            const SizedBox(height: 48),
            
            // Footer
             Text(
              "VHNSNC INDOOR SUPPORT",
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w700,
                color: Colors.grey.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: goldLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: goldAccent, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: primaryText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                         actionText,
                         style: const TextStyle(
                           color: goldAccent,
                           fontWeight: FontWeight.w600,
                           fontSize: 13,
                         ),
                      )
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@vhnsnc.edu.in',
      query: 'subject=Support Inquiry',
    );
    if (!await launchUrl(emailLaunchUri)) {
      debugPrint('Could not launch email');
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '+911234567890',
    );
    if (!await launchUrl(phoneLaunchUri)) {
      debugPrint('Could not launch phone');
    }
  }
}
