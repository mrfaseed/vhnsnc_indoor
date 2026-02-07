import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart' as app_config;




import 'forget_password_screen.dart';
import 'user/user_dashboard.dart';
import 'admin/admin_dashboard.dart'; // Suggesting adding this import for admin routing if file exists
import '../widgets/aurora_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController(); // Replaced password controller
  final _formKey = GlobalKey<FormState>();
  
  // OTP Logic
  final List<bool> _otpVisible = [false, false, false, false];
  final List<Timer?> _otpTimers = [null, null, null, null];
  final FocusNode _otpFocusNode = FocusNode();
  int _lastOtpLength = 0;

  bool _isLoading = false;
  String? _errorMessage;

  // Admin Password Logic
  bool _showPasswordInput = false;
  final _passwordController = TextEditingController(); 
  bool _obscurePassword = true;

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Yellow theme colors - professional palette
  static const Color _primaryYellow = Color(0xFFFFC107); // Amber
  static const Color _forgetpassYellow = Color(0xFF251A0D); // Amber darken-1
  static const Color _darkYellow = Color(0xFFFF8F00); // Amber darken-2
  static const Color _lightYellow = Color(0xFFFFECB3); // Amber lighten-4
  static const LinearGradient _background = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // Gold
      Color(0xFFF8C550), // Amber
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

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
    _otpController.dispose(); 
    _otpFocusNode.dispose();
    for (var timer in _otpTimers) {
      timer?.cancel();
    }
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
      final url = Uri.parse('${app_config.Config.baseUrl}/login.php');

      final startTime = DateTime.now();

      // Prepare body
      Map<String, String> body = {
        'email': _emailController.text,
        'pin': _otpController.text, 
      };

      if (_showPasswordInput) {
        body['password'] = _passwordController.text;
      }

      final response = await http.post(
        url,
        body: body,
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException("Connection timed out"),
      );

      final elapsedTime = DateTime.now().difference(startTime);
      final remainingTime = const Duration(seconds: 2) - elapsedTime;

      if (remainingTime > Duration.zero) {
        await Future.delayed(remainingTime);
      }

      if (!mounted) return;

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          
          if (data['success'] == true) {
            // Login Successful
             final prefs = await SharedPreferences.getInstance();
            
            if (data['token'] != null) {
              await prefs.setString('jwt_token', data['token']);
              
              if (data['user'] != null) {
                 await prefs.setString('user_id', data['user']['id'].toString());
                 await prefs.setString('user_name', data['user']['name']);
                 await prefs.setString('user_role', data['user']['role'] ?? 'user'); // Save Role
              }

              if (!mounted) return;

              // Navigate based on Role check or just dashboard
              // Assuming same dashboard for now or handling inside UserDashboard
              // But user explicitly asked for role based login.
              // If Admin, maybe different dashboard? 
              // Re-using UserDashboard for now as per previous code, or if you have AdminDashboard import it.
              // Previous admin_login.dart went to AdminDashboard.
              
              if (data['user']['role'] == 'admin') {
                 // Lazy import or route to AdminDashboard
                  // Since I can't import AdminDashboard directly if I don't know path, 
                  // I'll assume standard path or navigate to UserDashboard and let it handle/redirect 
                  // or better, I checked admin_login.dart content earlier: import './admin/admin_dashboard.dart';
                  // So I should import it here too.
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const AdminDashboard()) // Fixed import
                  );
              } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const UserDashboard()),
                  );
              }

            }
          } else if (data['require_password'] == true) {
            // Step 2: Ask for Admin Password
            setState(() {
              _showPasswordInput = true;
              _isLoading = false;
              _errorMessage = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("PIN Verified. Please enter your Admin Password.")),
            );
          } else {
            setState(() => _errorMessage = data['message'] ?? 'Login failed');
          }
        } catch (e) {
           setState(() => _errorMessage = "Invalid server response");
        }
      } else {
        setState(() => _errorMessage = "Server Error: ${response.statusCode}");
      }

    } on TimeoutException catch (_) {
      setState(() => _errorMessage = "Connection timed out. Please check your internet.");
    } on SocketException catch (_) {
      setState(() => _errorMessage = "No internet connection. Please check your network.");
    } catch (e) {
      setState(() => _errorMessage = "An unexpected error occurred: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Theme(
        data: Theme.of(context).copyWith(
          textTheme: Theme.of(context).textTheme.apply(fontFamily: 'Manrope'),
        ),
        child: AuroraBackground(
          colors: _background.colors,
          child: SafeArea(
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
                        _showPasswordInput ? "Admin Verification" : "Welcome Back",
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
                        _showPasswordInput 
                          ? "Please enter your password to continue" 
                          : "Sign in to continue to your account",
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
                             // Email & PIN Fields (Hide/Disable if in password step? Or keep visible)
                             // Requirements: "The password input must not be shown unless the entered PIN is valid."
                             // So we keep Email and PIN visible, maybe readonly?
                             
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
                              readOnly: _showPasswordInput, // Readonly in Step 2
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
  
                            // PIN Field
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                "Enter 4-Digit PIN",
                                 style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: _textPrimary,
                                ),
                              ),
                            ),
                            AbsorbPointer(
                              absorbing: _showPasswordInput, // Disable interaction in Step 2
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Hidden TextField
                                  Opacity(
                                    opacity: 0,
                                    child: TextFormField(
                                      controller: _otpController,
                                      focusNode: _otpFocusNode,
                                      keyboardType: TextInputType.number,
                                      maxLength: 4,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value.length > _lastOtpLength) {
                                            int index = value.length - 1;
                                            if (index < 4) {
                                              _otpVisible[index] = true;
                                              _otpTimers[index]?.cancel();
                                              _otpTimers[index] = Timer(const Duration(seconds: 2), () {
                                                if (mounted) {
                                                  setState(() {
                                                    _otpVisible[index] = false;
                                                  });
                                                }
                                              });
                                            }
                                          }
                                          _lastOtpLength = value.length;
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter PIN';
                                        }
                                        if (value.length != 4) {
                                          return 'PIN must be exactly 4 digits';
                                        }
                                        return null;
                                      },
                                      onFieldSubmitted: (_) => _handleLogin(),
                                    ),
                                  ),
                                  // Visible OTP Boxes
                                  GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).requestFocus(_otpFocusNode);
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: List.generate(4, (index) {
                                        String char = "";
                                        if (index < _otpController.text.length) {
                                          char = _otpController.text[index];
                                        }
                                        
                                        bool hasChar = char.isNotEmpty;
                                        bool isVisible = _otpVisible[index];
                                        bool isFocused = _otpFocusNode.hasFocus && index == _otpController.text.length;
                                        
                                        return AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          curve: Curves.easeInOut,
                                          width: 68,
                                          height: 72,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: hasChar 
                                                ? _surface 
                                                : (isFocused ? _surface : Colors.grey.withOpacity(0.08)), // Subtle fill for empty state
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(
                                              color: isFocused 
                                                  ? _primaryYellow 
                                                  : (hasChar ? _primaryYellow.withOpacity(0.5) : _borderColor.withOpacity(0.5)),
                                              width: isFocused ? 2.5 : 1.5,
                                            ),
                                            boxShadow: [
                                              if (isFocused)
                                                BoxShadow(
                                                  color: _primaryYellow.withOpacity(0.25),
                                                  blurRadius: 16,
                                                  spreadRadius: 2,
                                                  offset: const Offset(0, 4),
                                                )
                                              else if (hasChar)
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 2),
                                                ),
                                            ],
                                          ),
                                          child: Text(
                                          char.isEmpty ? "" : (isVisible ? char : "●"),
                                          style: TextStyle(
                                            fontSize: isVisible ? 28 : (char.isEmpty ? 28 : 24), // Adjust size for mask char
                                            fontWeight: FontWeight.w700,
                                            color: _textPrimary,
                                          ),
                                        ),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Step 2: Admin Password Field
                            if (_showPasswordInput) ...[
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  "Admin Password",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: _textPrimary,
                                  ),
                                ),
                              ),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  hintText: "Enter admin password",
                                  hintStyle: TextStyle(color: _textSecondary.withOpacity(0.6)),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  filled: true,
                                  fillColor: _surface,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _borderColor)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _primaryYellow, width: 2)),
                                ),
                                validator: (value) {
                                  if (_showPasswordInput && (value == null || value.isEmpty)) {
                                    return 'Please enter password';
                                  }
                                  return null;
                                },
                              ),
                            ],
  
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
                                _showPasswordInput ? "Verify & Login" : "Continue",
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
                      
                      const SizedBox(height: 40),
                      Center(
                        child: Text(
                          "© 2026 DigiTech, VHNSNC. All rights reserved.",
                          style: TextStyle(color: _textSecondary.withOpacity(0.5), fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}