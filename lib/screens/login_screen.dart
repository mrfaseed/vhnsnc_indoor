import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';


import 'admin_login.dart';
import 'forget_password_screen.dart';
import 'user/user_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
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

  // Yellow theme colors - professional palette
  static const Color _primaryYellow = Color(0xFFFFC107); // Amber
  static const Color _darkYellow = Color(0xFFFF8F00); // Amber darken-2
  static const Color _lightYellow = Color(0xFFFFECB3); // Amber lighten-4
  static const Color _background = Color(0xFFF8F9FA); // Light gray background
  static const Color _surface = Color(0xFFFFFFFF); // White surface
  static const Color _textPrimary = Color(0xFF212121); // Dark gray
  static const Color _textSecondary = Color(0xFF757575); // Medium gray
  static const Color _borderColor = Color(0xFFE0E0E0); // Light border
  static const Color _errorColor = Color(0xFFD32F2F); // Red for errors

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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse('${Config.baseUrl}/login.php');

      final startTime = DateTime.now();

      final response = await http.post(
        url,
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException("Connection timed out"),
      );

      final elapsedTime = DateTime.now().difference(startTime);
      final remainingTime = const Duration(seconds: 2) - elapsedTime;

      if (remainingTime > Duration.zero) {
        await Future.delayed(remainingTime);
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Store the token
          // Store the token
          debugPrint("LOGIN SCREEN: Response Body: ${response.body}");
          
          final prefs = await SharedPreferences.getInstance();
          
          if (data['token'] != null) {
            final token = data['token'];
            debugPrint("LOGIN SCREEN: Saving Token: $token");
            await prefs.setString('jwt_token', token);
            debugPrint("LOGIN SCREEN: Token Saved!");
          } else {
             debugPrint("LOGIN SCREEN: ERROR - Token is NULL in response!");
          }
          // You can also store user data here if needed (e.g. using SharedPreferences)
          // final user = data['user']; 

          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserDashboard()),
          );
        } else {
          setState(() => _errorMessage = data['message'] ?? 'Login failed');
        }
      } else {
        setState(() => _errorMessage = "Server Error: ${response.statusCode}");
      }

    } catch (e) {
      // This catches "Signal 3" related crashes or network errors
      setState(() => _errorMessage = "An unexpected error occurred: $e");
    } finally {
      // ALWAYS happens, even if code crashes, ensuring button becomes clickable again
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo / Branding
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _surface,
                        boxShadow: [
                          BoxShadow(
                            color: _primaryYellow.withOpacity(0.1),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: _lightYellow,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.sports_tennis,
                        size: 48,
                        color: _primaryYellow,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Header
                    Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sign in to continue to your account",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: _textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Error message
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
                              Icons.error_outline_rounded,
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
                          // Email field
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              "Email or Username",
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
                              hintText: "Enter email or username",
                              hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6)),
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: _textSecondary,
                              ),
                              filled: true,
                              fillColor: _surface,
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
                                borderSide: BorderSide(color: _primaryYellow, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email or username';
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
                                  "Password",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: _textPrimary,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const ForgotPasswordScreen(),
                                      ),
                                    );
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: _primaryYellow,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
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
                              hintText: "Enter your password",
                              hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6)),
                              prefixIcon: Icon(
                                Icons.lock_outline_rounded,
                                color: _textSecondary,
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
                              fillColor: _surface,
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
                                borderSide: BorderSide(color: _primaryYellow, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sign In button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryYellow,
                          foregroundColor: _textPrimary,
                          disabledBackgroundColor: _primaryYellow.withOpacity(0.5),
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
                              "Sign In",
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

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminLoginScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: _textSecondary,
                      ),
                      child: Text(
                        "Admin Login",
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 14,
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
    );
  }
}