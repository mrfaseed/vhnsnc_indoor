import 'package:flutter/material.dart';
import 'dart:async';
import './admin/admin_dashboard.dart';
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Yellow theme colors - consistent with LoginScreen
  static const Color _primaryYellow = Color(0xFFFFC107); // Amber
  static const Color _darkYellow = Color(0xFFFF8F00); // Amber darken-2
  static const Color _lightYellow = Color(0xFFFFECB3); // Amber lighten-4
  static const Color _accentYellow = Color(0xFFFFD54F); // Amber lighten-2
  static const Color _background = Color(0xFFF8F9FA); // Light gray background
  static const Color _surface = Color(0xFFFFFFFF); // White surface
  static const Color _textPrimary = Color(0xFF212121); // Dark gray
  static const Color _textSecondary = Color(0xFF757575); // Medium gray
  static const Color _borderColor = Color(0xFFE0E0E0); // Light border
  static const Color _errorColor = Color(0xFFD32F2F); // Red for errors
  static const Color _adminAccent = Color(0xFF795548); // Brown accent for admin

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleAdminLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Mock Admin Logic (admin@club.com)
    if (_emailController.text == 'admin@gmail.com' &&
        _passwordController.text == 'admin123') {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome, ${_emailController.text}"),
          backgroundColor: _darkYellow,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );

      // Use pushReplacement with MaterialPageRoute
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      setState(() => _errorMessage = 'Invalid admin credentials');
    }

    if (mounted && _errorMessage != null) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Check if screen is wide enough for split view (Tablet/Desktop)
          bool isWideScreen = constraints.maxWidth > 800;

          return Row(
            children: [
              // --- Left Side: Branding (Hidden on Mobile) ---
              if (isWideScreen)
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _darkYellow.withOpacity(0.9),
                          _primaryYellow,
                          _accentYellow,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Admin Badge
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _darkYellow.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          "Admin Portal",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            "Access to club management, member analytics, and administrative controls",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Security Features
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                "Enterprise-grade Security",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // --- Right Side: Login Form ---
              Expanded(
                flex: 1,
                child: Container(
                  color: _surface,
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(32),
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Mobile Header (Only visible if Left Side is hidden)
                                if (!isWideScreen) ...[
                                  Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _primaryYellow.withOpacity(0.1),
                                      border: Border.all(
                                        color: _primaryYellow.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.admin_panel_settings_rounded,
                                      size: 48,
                                      color: _primaryYellow,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    "Admin Login",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w700,
                                      color: _textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Access to administration panel",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _textSecondary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                ] else ...[
                                  // Desktop Header
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: _primaryYellow.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _primaryYellow.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.admin_panel_settings_rounded,
                                          size: 32,
                                          color: _primaryYellow,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Admin Authentication",
                                            style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w700,
                                              color: _textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "Please enter your credentials",
                                            style: TextStyle(
                                              color: _textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 32),
                                ],

                                // Error Box
                                if (_errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: _errorColor.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _errorColor.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          color: _errorColor,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: _errorColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                // Form
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Admin Email field
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Text(
                                          "Admin Email",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: _textPrimary,
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        style: TextStyle(color: _textPrimary),
                                        decoration: InputDecoration(
                                          hintText: "admin@club.com",
                                          hintStyle: TextStyle(
                                              color: _textSecondary.withOpacity(0.6)),
                                          prefixIcon: Icon(
                                            Icons.admin_panel_settings_outlined,
                                            color: _adminAccent,
                                          ),
                                          filled: true,
                                          fillColor: _background,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: _borderColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: _borderColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: _primaryYellow, width: 2),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter admin email';
                                          }
                                          if (!value.contains('@')) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 20),

                                      // Password field
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Admin Password",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: _textPrimary,
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        style: TextStyle(color: _textPrimary),
                                        decoration: InputDecoration(
                                          hintText: "Enter admin password",
                                          hintStyle: TextStyle(
                                              color: _textSecondary.withOpacity(0.6)),
                                          prefixIcon: Icon(
                                            Icons.lock_outline_rounded,
                                            color: _adminAccent,
                                          ),
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              color: _textSecondary,
                                            ),
                                          ),
                                          filled: true,
                                          fillColor: _background,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: _borderColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: _borderColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: _primaryYellow, width: 2),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter admin password';
                                          }
                                          if (value.length < 6) {
                                            return 'Password must be at least 6 characters';
                                          }
                                          return null;
                                        },
                                        onFieldSubmitted: (_) => _handleAdminLogin(),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Sign In button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleAdminLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _primaryYellow,
                                      foregroundColor: _textPrimary,
                                      disabledBackgroundColor:
                                      _primaryYellow.withOpacity(0.5),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    child: _isLoading
                                        ? SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: _textPrimary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Sign In as Admin",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                          color: _textPrimary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: _borderColor,
                                        thickness: 1,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "OR",
                                        style: TextStyle(
                                          color: _textSecondary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Divider(
                                        color: _borderColor,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Back to Member Login
                                SizedBox(
                                  height: 56,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: _textSecondary,
                                      side: BorderSide(color: _borderColor),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    icon: Icon(
                                      Icons.arrow_back_rounded,
                                      color: _textSecondary,
                                      size: 20,
                                    ),
                                    label: Text(
                                      "Back to Member Login",
                                      style: TextStyle(
                                        color: _textSecondary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}