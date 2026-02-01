import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class MakePaymentScreen extends StatefulWidget {
  const MakePaymentScreen({super.key});

  @override
  State<MakePaymentScreen> createState() => _MakePaymentScreenState();
}

class _MakePaymentScreenState extends State<MakePaymentScreen> {
  bool _isProcessing = false;
  final int _membershipAmount = 1200;

  // Benefits list
  final List<String> _benefits = [
    'Unlimited court access',
    'Free equipment rental',
    'Professional coaching sessions',
    'Priority court booking',
    'Tournament participation',
    'Locker facilities'
  ];

  // Logic to simulate payment
  Future<void> _handlePayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate network/Razorpay delay (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // Generate mock payment ID
    final String razorpayId = "pay_${Random().nextInt(1000000).toString().padLeft(6, '0')}";

    setState(() {
      _isProcessing = false;
    });

    // Navigate to Success Screen ( need to create this next)

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful! ID: $razorpayId")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDE7), Colors.white], // yellow-50 to white
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildPaymentSummary(),
                      const SizedBox(height: 20),
                      _buildBenefitsList(),
                      const SizedBox(height: 20),
                      _buildPaymentMethod(),
                      const SizedBox(height: 32),
                      _buildPayButton(),
                      const SizedBox(height: 16),
                      const Text(
                        "Secure payment powered by Razorpay",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. App Bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
          const Text("Make Payment", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // 2. Summary Card
  Widget _buildPaymentSummary() {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payment Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _summaryRow("Membership Type", "Annual"),
          const Divider(color: Color(0xFFFFF9C4)),
          _summaryRow("Duration", "12 Months"),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Total Amount", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text("₹$_membershipAmount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Benefits Card
  Widget _buildBenefitsList() {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Membership Benefits", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ..._benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.yellow.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.check, size: 12, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Text(benefit, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // 4. Payment Method Card
  Widget _buildPaymentMethod() {
    return _buildCardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Payment Method", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDE7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow, width: 2),
            ),
            child: const Row(
              children: [
                Icon(Icons.credit_card, color: Colors.orange),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Razorpay", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("Secure payment gateway", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Action Button
  Widget _buildPayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.yellow.shade600,
          foregroundColor: Colors.black87,
          shape: RoundedRectangleType(20), // Custom extension below
          elevation: 2,
        ),
        child: _isProcessing
            ? const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
            SizedBox(width: 12),
            Text("Processing Payment..."),
          ],
        )
            : Text("Pay ₹$_membershipAmount Now", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  // Helper: Card Wrapper
  Widget _buildCardWrapper({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.yellow.shade200, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// Custom Shape Helper
RoundedRectangleBorder RoundedRectangleType(double radius) {
  return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}