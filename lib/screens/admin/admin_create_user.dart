import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart' as app_config;
import '../../widgets/aurora_background.dart';

class AdminCreateUser extends StatefulWidget {
  const AdminCreateUser({super.key});

  @override
  State<AdminCreateUser> createState() => _AdminCreateUserState();
}

class _AdminCreateUserState extends State<AdminCreateUser> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController(); // Added password field as requested
  
  String _membershipStatus = 'unpaid';
  int _durationMonths = 1;
  bool _isLoading = false;

  // Theme Colors
  static const Color _primaryGold = Color(0xFFFFC107);
  static const Color _textPrimary = Color(0xFF212121);

  Future<void> _createUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('${app_config.Config.baseUrl}/admin_create_user.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": _nameController.text,
          "email": _emailController.text,
          "phone": _phoneController.text,
          "password": _passwordController.text,
          "membership_status": _membershipStatus,
          "duration_months": _membershipStatus == 'paid' ? _durationMonths : 0,
        }),
      );

      final data = jsonDecode(response.body);

      if (mounted) {
        setState(() => _isLoading = false);
        if (data['success'] == true) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User created successfully!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message']), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuroraBackground(
        colors: const [Colors.white, Color(0xFFFFF8E1)], // Light Gold
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: _textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Create New User",
                      style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: _textPrimary),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Personal Details"),
                          const SizedBox(height: 16),
                          _buildTextField("Full Name", Icons.person_outline, _nameController),
                          const SizedBox(height: 16),
                          _buildTextField("Email Address", Icons.email_outlined, _emailController, type: TextInputType.emailAddress),
                          const SizedBox(height: 16),
                          _buildTextField("Mobile Number", Icons.phone_outlined, _phoneController, type: TextInputType.phone),
                          const SizedBox(height: 16),
                          _buildTextField("Password", Icons.lock_outline, _passwordController, type: TextInputType.visiblePassword, isPassword: true),
                          
                          const SizedBox(height: 32),
                          _buildSectionTitle("Membership"),
                          const SizedBox(height: 16),
                          
                          // Membership Status Dropdown
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: _membershipStatus,
                                items: const [
                                  DropdownMenuItem(value: 'unpaid', child: Text("Unpaid Member")),
                                  DropdownMenuItem(value: 'paid', child: Text("Paid Member (Active)")),
                                ],
                                onChanged: (val) => setState(() => _membershipStatus = val!),
                              ),
                            ),
                          ),

                          // Conditional Duration Input
                          if (_membershipStatus == 'paid') ...[
                            const SizedBox(height: 24),
                            Text("Membership Duration (Months)", style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Slider(
                              value: _durationMonths.toDouble(),
                              min: 1,
                              max: 12,
                              divisions: 11,
                              activeColor: _primaryGold,
                              label: "$_durationMonths Month${_durationMonths > 1 ? 's' : ''}",
                              onChanged: (val) => setState(() => _durationMonths = val.toInt()),
                            ),
                            Center(
                              child: Text(
                                "$_durationMonths Month${_durationMonths > 1 ? 's' : ''}",
                                style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],

                          const SizedBox(height: 40),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _createUser,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryGold,
                                foregroundColor: _textPrimary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Create User", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
    );
  }

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType? type, bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      obscureText: isPassword,
      validator: (value) => value!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _primaryGold, width: 2)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
