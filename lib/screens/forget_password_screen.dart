import 'package:flutter/material.dart';
import 'dart:async';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Page State
  int _currentStep = 0; // 0: Email, 1: Verify, 2: Success
  bool _isLoading = false;
  String? _errorMessage;

  // Controllers
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Mock Data
  final String _maskedNumberHint = "•••• •••• 43";

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // --- Logic ---

  void _handleNextStep() async {
    setState(() => _errorMessage = null);

    // Validation Step 0 (Email)
    if (_currentStep == 0) {
      if (!_emailController.text.contains('@') || _emailController.text.isEmpty) {
        setState(() => _errorMessage = "Please enter a valid email address");
        return;
      }
    }

    // Validation Step 1 (Security Questions)
    if (_currentStep == 1) {
      if (_nameController.text.isEmpty) {
        setState(() => _errorMessage = "Please enter your full name");
        return;
      }
      if (_phoneController.text.length < 10) {
        setState(() => _errorMessage = "Please enter a valid phone number");
        return;
      }
      // Mock Check: Ensure they typed a number ending in 43
      if (!_phoneController.text.endsWith('43')) {
        setState(() => _errorMessage = "Number does not match the record (must end in 43)");
        return;
      }
    }

    // Simulate Network Call
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _currentStep++; // Go to next step
    });
  }

  void _goBack() {
    if (_currentStep > 0 && _currentStep < 2) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Yellow Theme Colors
    const bgYellow = Color(0xFFFFFFFF);       // Very Light Yellow Background
    const surfaceWhite = Colors.white;        // Pure White Cards/Inputs
    const accentYellow = Color(0xFFFFC107);    // Amber/Yellow Primary
    const textMain = Color(0xFF422006);       // Deep Brown/Yellow Text (Better contrast than black)
    const textSub = Color(0xFF713F12);        // Muted Brown Text

    return Scaffold(
      backgroundColor: bgYellow,
      appBar: AppBar(
        backgroundColor: bgYellow,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textMain),
          onPressed: _goBack,
        ),
        title: const Text(
          "Account Recovery",
          style: TextStyle(color: textMain, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress Bar
              Row(
                children: [
                  _buildProgressDot(0, accentYellow),
                  _buildProgressLine(0, accentYellow, Colors.amber.shade100),
                  _buildProgressDot(1, accentYellow),
                  _buildProgressLine(1, accentYellow, Colors.amber.shade100),
                  _buildProgressDot(2, accentYellow),
                ],
              ),
              const SizedBox(height: 40),

              // Animated Content Switcher
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.2, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: _buildCurrentStep(surfaceWhite, textMain, textSub, accentYellow),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(Color surface, Color textMain, Color textSub, Color accent) {
    switch (_currentStep) {
      case 0:
        return _buildStepOne(surface, textMain, textSub, accent);
      case 1:
        return _buildStepTwo(surface, textMain, textSub, accent);
      case 2:
        return _buildSuccessStep(textMain, textSub, accent);
      default:
        return Container();
    }
  }

  // --- Step 1: Email ---
  Widget _buildStepOne(Color surface, Color textMain, Color textSub, Color accent) {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Find your account",
          style: TextStyle(color: Color(0xFF422006), fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          "Enter your email address to search for your account.",
          style: TextStyle(color: Color(0xFF713F12), fontSize: 16),
        ),
        const SizedBox(height: 32),
        _buildErrorBox(),
        _buildLightInput(
          label: "Email",
          controller: _emailController,
          icon: Icons.mail_outline,
          inputType: TextInputType.emailAddress,
          accent: accent,
        ),
        const Spacer(),
        _buildButton("Next", accent),
      ],
    );
  }

  // --- Step 2: Verification ---
  Widget _buildStepTwo(Color surface, Color textMain, Color textSub, Color accent) {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify it's you",
          style: TextStyle(color: Color(0xFF422006), fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Info Box (Yellow Version)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.perm_device_information, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Enter the mobile number that ends with  $_maskedNumberHint",
                  style: TextStyle(color: Colors.amber.shade900, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _buildErrorBox(),
        _buildLightInput(
          label: "Full Name",
          controller: _nameController,
          icon: Icons.person_outline,
          accent: accent,
        ),
        const SizedBox(height: 16),
        _buildLightInput(
          label: "Mobile Number",
          controller: _phoneController,
          icon: Icons.phone_android,
          inputType: TextInputType.phone,
          accent: accent,
        ),
        const Spacer(),
        _buildButton("Submit", accent),
      ],
    );
  }

  // --- Step 3: Success ---
  Widget _buildSuccessStep(Color textMain, Color textSub, Color accent) {
    return Column(
      key: const ValueKey(2),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read, color: accent, size: 50),
        ),
        const SizedBox(height: 32),
        const Text(
          "Email Sent!",
          style: TextStyle(color: Color(0xFF422006), fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Text(
          "We have sent a password reset link to ${_emailController.text}.",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF713F12), fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.amber.shade200),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Back to Login", style: TextStyle(color: Color(0xFF713F12), fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildButton(String text, Color color) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleNextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color(0xFF422006), // Dark text on yellow button
          disabledBackgroundColor: color.withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF422006), strokeWidth: 2))
            : Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildErrorBox() {
    if (_errorMessage == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        border: Border.all(color: const Color(0xFFFECACA)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFF991B1B)))),
        ],
      ),
    );
  }

  Widget _buildLightInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color accent,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          )
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        style: const TextStyle(color: Color(0xFF422006), fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.amber.shade700.withOpacity(0.7)),
          prefixIcon: Icon(icon, color: Colors.amber.shade300),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accent, width: 2),
          ),
        ),
      ),
    );
  }

  // Progress Indicators
  Widget _buildProgressDot(int stepIndex, Color color) {
    bool isActive = _currentStep >= stepIndex;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? color : Colors.transparent,
        border: Border.all(color: isActive ? color : Colors.amber.shade200),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildProgressLine(int stepIndex, Color activeColor, Color inactiveColor) {
    bool isActive = _currentStep > stepIndex;
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? activeColor : inactiveColor,
      ),
    );
  }
}