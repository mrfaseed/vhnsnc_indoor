import 'package:flutter/material.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  // Theme Constants
  static const Color goldAccent = Color(0xFFC5A028);
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
          'ABOUT APP',
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
        child: Column(
          children: [
            const SizedBox(height: 48),
            
            // App Logo Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                         BoxShadow(
                          color: goldAccent.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(color: goldAccent.withOpacity(0.1), width: 1),
                    ),
                    child: const Icon(Icons.sports_tennis, size: 48, color: goldAccent),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "VHNSNC INDOOR",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: primaryText,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: goldAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Version 2.0  ",
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: goldAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),

            // Info Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "APPLICATION INFO",
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      color: secondaryText, 
                      letterSpacing: 1.5
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoTile(
                          icon: Icons.developer_mode_rounded,
                          title: "Developer",
                          value: "DigitTech Vhnsnc",
                        ),
                        const Divider(height: 1, indent: 60),
                        _buildInfoTile(
                          icon: Icons.update_rounded,
                          title: "Last Updated",
                          value: "February 2026",
                        ),
                        const Divider(height: 1, indent: 60),
                         _buildInfoTile(
                          icon: Icons.shield_outlined,
                          title: "License",
                          value: "Active",
                          isHighLight: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  const Text(
                    "DESCRIPTION",
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.bold, 
                      color: secondaryText, 
                      letterSpacing: 1.5
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                         BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Text(
                      "VHNSNC Indoor Stadium app provides a seamless experience for members to manage their subscriptions,  and stay updated with the latest announcements. Designed for premium convenience and reliability.",
                      style: TextStyle(
                        color: secondaryText,
                        height: 1.6,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 48),
            
            Center(
               child: Text(
                "© 2026 DigiTech, VHNSNC. All rights reserved ",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    bool isHighLight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: secondaryText),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: primaryText,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isHighLight ? FontWeight.bold : FontWeight.w500,
              color: isHighLight ? goldAccent : secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}
