import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config.dart' as app_config;

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<Map<String, dynamic>> payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshPayments();
  }

  Future<void> _refreshPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id');

    if (userId == null) {
      if (mounted) setState(() {
         payments = [];
         _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('${app_config.Config.baseUrl}/get_payment_history.php?user_id=$userId'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> rawList = data['data'];
          
          if(mounted) {
            setState(() {
              payments = rawList.map((item) {
                 // Format Date safely
                 String dateStr = item['payment_date'] ?? '';
                 String displayDate = dateStr;
                 try{
                   DateTime dt = DateTime.parse(dateStr);
                   displayDate = "${dt.day} ${_monthName(dt.month)} ${dt.year}";
                 } catch(e) {}

                 return {
                  "title": item['description'] ?? 'Payment',
                  "date": displayDate,
                  "amount": "₹${item['amount']}",
                  "success": (item['payment_status'] == 'success'), 
                 };
              }).toList();
              _isLoading = false;
            });
          }
        } else {
             if(mounted) setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Error fetching payments: $e");
       if(mounted) setState(() => _isLoading = false);
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading 
         ? const Center(child: CircularProgressIndicator(color: Colors.blue))
         : RefreshIndicator(
        onRefresh: _refreshPayments,
        child: payments.isEmpty 
           ? const Center(child: Text("No payment history found.")) 
           : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final item = payments[index];
            return AnimatedPaymentTile(
              title: item["title"],
              date: item["date"],
              amount: item["amount"],
              isSuccess: item["success"],
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}

class AnimatedPaymentTile extends StatefulWidget {
  final String title;
  final String date;
  final String amount;
  final bool isSuccess;
  final VoidCallback onTap;

  const AnimatedPaymentTile({
    super.key,
    required this.title,
    required this.date,
    required this.amount,
    required this.isSuccess,
    required this.onTap,
  });

  @override
  State<AnimatedPaymentTile> createState() => _AnimatedPaymentTileState();
}

class _AnimatedPaymentTileState extends State<AnimatedPaymentTile> {
  double scale = 1.0;

  void _onTapDown(_) {
    setState(() => scale = 0.97);
  }

  void _onTapUp(_) {
    setState(() => scale = 1.0);
    widget.onTap();
  }

  void _onTapCancel() {
    setState(() => scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: widget.isSuccess
                        ? const Color(0xFFD1FAE5)
                        : const Color(0xFFFEE2E2),
                    child: Icon(
                      widget.isSuccess
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                      widget.isSuccess ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.date,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.amount,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.isSuccess ? "Success" : "Failed",
                    style: TextStyle(
                      color: widget.isSuccess
                          ? Colors.green
                          : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
