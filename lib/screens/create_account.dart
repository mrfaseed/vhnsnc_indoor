import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _errorMessage;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPassController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _errorMessage = null;
    });

    if (_passwordController.text != _confirmPassController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    if (_passwordController.text.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters');
      return;
    }

    if (_phoneController.text.length != 10) {
      setState(() => _errorMessage = 'Phone number must be exactly 10 digits');
      return;
    }

    setState(() => _isLoading = true);
    // await Future.delayed(const Duration(seconds: 2)); // Removed delay

    try {
      final url = Uri.parse('${Config.baseUrl}  ');

      final response = await http.post(
        url,
        body: {
          'name': _nameController.text,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException("Connection timed out"),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account Created! Please login."),
              backgroundColor: Colors.amber, 
            ),
          );
          
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) Navigator.pop(context); // Go back to login
        } else {
          setState(() => _errorMessage = data['message'] ?? 'Registration failed');
        }
      } else {
        setState(() => _errorMessage = "Server Error: ${response.statusCode}");
      }

    } catch (e) {
      setState(() => _errorMessage = 'Connection Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Professional Admin Palette
    const Color primaryYellow = Color(0xFFFFC107);
    const Color background = Color(0xFFF8F9FA);
    const Color surface = Color(0xFFFFFFFF);
    const Color textPrimary = Color(0xFF212121);
    const Color textSecondary = Color(0xFF757575);
    const Color borderColor = Color(0xFFE0E0E0);
    const Color errorRed = Color(0xFFD32F2F);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Create New User",
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  // Header Text
                  const Text(
                    "User Details",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Fill in the information below to register a new member.",
                    style: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- Error Message Box ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _errorMessage != null
                        ? Container(
                      key: ValueKey(_errorMessage),
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: errorRed.withOpacity(0.05),
                        border: Border.all(color: errorRed.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.error_outline_rounded, color: errorRed, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: errorRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),

                  // --- Form Fields ---
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildModernInput(
                          label: "Full Name",
                          controller: _nameController,
                          icon: Icons.person_outline_rounded,
                          borderColor: borderColor,
                          activeColor: primaryYellow,
                          textColor: textPrimary,
                        ),
                        const SizedBox(height: 20),
                        _buildModernInput(
                          label: "Email Address",
                          controller: _emailController,
                          icon: Icons.alternate_email_rounded,
                          inputType: TextInputType.emailAddress,
                          borderColor: borderColor,
                          activeColor: primaryYellow,
                          textColor: textPrimary,
                        ),
                        const SizedBox(height: 20),
                        _buildModernInput(
                          label: "Phone Number",
                          controller: _phoneController,
                          icon: Icons.smartphone_rounded,
                          inputType: TextInputType.phone,
                          prefixText: "+91 ",
                          maxLength: 10,
                          borderColor: borderColor,
                          activeColor: primaryYellow,
                          textColor: textPrimary,
                        ),
                        const SizedBox(height: 20),
                        
                        // Password
                        _buildModernInput(
                          label: "Password",
                          controller: _passwordController,
                          icon: Icons.lock_outline_rounded,
                          obscureText: _obscurePassword,
                          toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                          isPassword: true,
                          borderColor: borderColor,
                          activeColor: primaryYellow,
                          textColor: textPrimary,
                        ),

                        const SizedBox(height: 20),
                        
                        // Confirm Password
                        _buildModernInput(
                          label: "Confirm Password",
                          controller: _confirmPassController,
                          icon: Icons.lock,
                          obscureText: _obscureConfirmPassword,
                          toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          isPassword: true,
                          borderColor: borderColor,
                          activeColor: primaryYellow,
                          textColor: textPrimary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- Submit Button ---
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryYellow,
                        foregroundColor: textPrimary,
                        disabledBackgroundColor: primaryYellow.withOpacity(0.5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: textPrimary,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Modern Input Helper ---
  Widget _buildModernInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color borderColor,
    required Color activeColor,
    required Color textColor,
    TextInputType inputType = TextInputType.text,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? toggleObscure,
    String? prefixText,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: inputType,
          style: TextStyle(
            color: textColor, 
            fontSize: 15, 
            fontWeight: FontWeight.w500
          ),
          maxLength: maxLength,
          cursorColor: activeColor,
          decoration: InputDecoration(
            counterText: "",
            hintText: "Enter ${label.toLowerCase()}",
            hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 22),
            prefixText: prefixText,
            prefixStyle: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 15),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Colors.grey.shade400,
                      size: 22,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: activeColor, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}