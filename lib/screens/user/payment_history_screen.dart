import 'package:flutter/material.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  List<Map<String, dynamic>> payments = [
    {
      "title": "Monthly Membership",
      "date": "12 Dec 2025",
      "amount": "₹300",
      "success": true,
    },
    {
      "title": "Monthly Membership",
      "date": "12 Nov 2025",
      "amount": "₹300",
      "success": true,
    },
    {
      "title": "Membership Renewal",
      "date": "12 Oct 2025",
      "amount": "₹300",
      "success": false,
    },
  ];

  /// 🔄 Pull to refresh logic
  Future<void> _refreshPayments() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      payments = List.from(payments.reversed);
    });
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
      body: RefreshIndicator(
        onRefresh: _refreshPayments,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: payments.length,
          itemBuilder: (context, index) {
            final item = payments[index];
            return AnimatedPaymentTile(
              title: item["title"],
              date: item["date"],
              amount: item["amount"],
              isSuccess: item["success"],
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment tapped")),
                );
              },
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
