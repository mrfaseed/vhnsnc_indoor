import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

// --- Models ---
class UserAccount {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String membershipStatus; // 'paid', 'unpaid'
  final DateTime memberSince;
  final DateTime membershipExpiry;

  UserAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.membershipStatus,
    required this.memberSince,
    required this.membershipExpiry,
  });

  factory UserAccount.fromJson(Map<String, dynamic> json) {
    return UserAccount(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      membershipStatus: json['membership_status'] ?? 'unpaid',
      memberSince: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      membershipExpiry: DateTime.tryParse(json['membership_expiry'] ?? '') ?? DateTime.now(),
    );
  }
}

class UserPayment {
  final String id;
  final double amount;
  final DateTime date;
  final String status; // 'success', 'failed'

  UserPayment({required this.id, required this.amount, required this.date, required this.status});

  factory UserPayment.fromJson(Map<String, dynamic> json) {
    return UserPayment(
      id: json['id'].toString(),
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      date: DateTime.tryParse(json['payment_date'] ?? '') ?? DateTime.now(),
      status: json['payment_status'] ?? 'success',
    );
  }
}

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  UserAccount? user;
  List<UserPayment> payments = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Fetch User Details
      final userResponse = await http.get(Uri.parse('${Config.baseUrl}/get_user_details.php?user_id=${widget.userId}'));
      
      // 2. Fetch Payment History
      final paymentResponse = await http.get(Uri.parse('${Config.baseUrl}/get_payment_history.php?user_id=${widget.userId}'));

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        
        if (userData['success'] == true) {
          final userObj = UserAccount.fromJson(userData['data']);
          
          List<UserPayment> paymentList = [];
          if (paymentResponse.statusCode == 200) {
            final paymentData = json.decode(paymentResponse.body);
            if (paymentData['success'] == true) {
              paymentList = (paymentData['data'] as List).map((e) => UserPayment.fromJson(e)).toList();
            }
          }

          if (mounted) {
            setState(() {
              user = userObj;
              payments = paymentList;
              _isLoading = false;
            });
          }
        } else {
           _setError("User not found via API");
        }
      } else {
        _setError("Server Error: ${userResponse.statusCode}");
      }
    } catch (e) {
      _setError("Network Error: $e");
    }
  }

  void _setError(String msg) {
    if (mounted) {
      setState(() {
        _errorMessage = msg;
        _isLoading = false;
      });
    }
  }

  // Handle status update
  Future<void> _handleStatusUpdate(String status) async {
    setState(() => _isLoading = true);
    
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/update_user_status.php'),
        body: {
          'user_id': widget.userId,
          'status': status,
        },
      );
      
      final data = json.decode(response.body);
      
      if (data['success'] == true) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("User marked as $status!")),
           );
           _fetchData(); // Refresh data to show new status/expiry
        }
      } else {
        _setError(data['message'] ?? "Update failed");
      }
    } catch (e) {
      _setError("Network error: $e");
    } finally {
      // _isLoading is handled by _fetchData inside success, but if error/loading needs reset:
     if (mounted && user == null) setState(() => _isLoading = false); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFB),
      appBar: AppBar(
        title: const Text("User Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.amber))
        : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : user == null
            ? const Center(child: Text("User data unavailable"))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: LayoutBuilder(builder: (context, constraints) {
                        bool isWide = constraints.maxWidth > 900;
                        return isWide
                            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 2, child: _buildMainContent()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildSideActions()),
                        ])
                            : Column(children: [
                          _buildMainContent(),
                          const SizedBox(height: 20),
                          _buildSideActions(),
                        ]);
                      }),
                    ),
                  ],
                ),
              ),
    );
  }

  // --- UI Components ---

  Widget _buildMainContent() {
    return Column(
      children: [
        // Profile Card
        _buildCard(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.amber[400]!, Colors.amber[800]!]),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(user!.name.isNotEmpty ? user!.name[0] : '?', style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(user!.email, style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        _buildBadge(
                          user!.membershipStatus == 'paid' ? 'Active Member' : 'Inactive Member',
                          user!.membershipStatus == 'paid' ? Colors.green : Colors.red,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Divider(height: 40),
              _buildInfoRow(Icons.email_outlined, "Email", user!.email),
              _buildInfoRow(Icons.phone_outlined, "Phone Number", user!.phone),
              _buildInfoRow(Icons.calendar_today_outlined, "Member Since", DateFormat('MMMM dd, yyyy').format(user!.memberSince)),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Membership details
        _buildCard(
          title: "Membership Details",
          child: Column(
            children: [
              _buildDetailRow("Member ID", user!.id.toUpperCase()),
              _buildDetailRow("Status", user!.membershipStatus == 'paid' ? "Active" : "Inactive", isStatus: true),
              _buildDetailRow("Expiry Date", DateFormat('MMMM dd, yyyy').format(user!.membershipExpiry), isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Payment History
        _buildCard(
          title: "Payment History",
          child: payments.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No payment history")))
              : Column(
            children: payments.map((p) => _buildPaymentItem(p)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSideActions() {
    return Column(
      children: [
        _buildCard(
          title: "Actions",
          child: Column(
            children: [
              _buildActionButton("Mark as Paid", Icons.check_circle, Colors.green, () => _handleStatusUpdate('paid')),
              const SizedBox(height: 12),
              _buildActionButton("Mark as Unpaid", Icons.cancel, Colors.red, () => _handleStatusUpdate('unpaid')),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Quick Stats", style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _buildStatRow("Total Payments", "${payments.length}"),
              _buildStatRow("Total Paid", "₹${payments.fold(0.0, (sum, p) => sum + p.amount).toStringAsFixed(0)}"),
            ],
          ),
        )
      ],
    );
  }

  // --- Small Reusable Helpers ---

  Widget _buildCard({required Widget child, String? title}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
          ],
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber[700], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          ]))
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[100]!))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600])),
          isStatus
              ? _buildBadge(value, value == "Active" ? Colors.green : Colors.red)
              : Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPaymentItem(UserPayment p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("₹${p.amount}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(DateFormat('MMM dd, yyyy').format(p.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ]),
          _buildBadge(p.status.toUpperCase(), p.status == 'success' ? Colors.green : Colors.red),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.amber[800])),
        Text(value, style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold)),
      ],
    );
  }
}