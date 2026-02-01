import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Model for Payment Data
class Payment {
  final String id;
  final String userName;
  final double amount;
  final DateTime date;
  final String razorpayPaymentId;
  final String status; // 'success', 'pending', 'failed'

  Payment({
    required this.id,
    required this.userName,
    required this.amount,
    required this.date,
    required this.razorpayPaymentId,
    required this.status,
  });
}

class PaymentsOverview extends StatefulWidget {
  const PaymentsOverview({super.key});

  @override
  State<PaymentsOverview> createState() => _PaymentsOverviewState();
}

class _PaymentsOverviewState extends State<PaymentsOverview> {
  String filterStatus = 'all';

  // Mock Data (In a real app, this comes from your Provider/Data Context)
  final List<Payment> payments = [
    Payment(id: 'tx101', userName: 'John Doe', amount: 5000, date: DateTime.now(), razorpayPaymentId: 'pay_Nsh291', status: 'success'),
    Payment(id: 'tx102', userName: 'Jane Smith', amount: 1200, date: DateTime.now(), razorpayPaymentId: 'pay_Msh882', status: 'pending'),
    Payment(id: 'tx103', userName: 'Alex Carry', amount: 3500, date: DateTime.now(), razorpayPaymentId: 'pay_Lsh112', status: 'failed'),
  ];

  List<Payment> get filteredPayments {
    if (filterStatus == 'all') return payments;
    return payments.where((p) => p.status == filterStatus).toList();
  }

  // Stats Calculations
  double get totalRevenue => payments.where((p) => p.status == 'success').fold(0, (sum, p) => sum + p.amount);
  int get successfulCount => payments.where((p) => p.status == 'success').length;
  int get pendingCount => payments.where((p) => p.status == 'pending').length;
  int get failedCount => payments.where((p) => p.status == 'failed').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F7), // Very light cream background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment Overview',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Stats Grid ---
            LayoutBuilder(builder: (context, constraints) {
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildStatCard('Total Revenue', '₹${totalRevenue.toStringAsFixed(0)}', Colors.amber[800]!, constraints),
                  _buildStatCard('Successful', '$successfulCount', Colors.green, constraints),
                  _buildStatCard('Pending', '$pendingCount', Colors.amber[600]!, constraints),
                  _buildStatCard('Failed', '$failedCount', Colors.red, constraints),
                ],
              );
            }),

            const SizedBox(height: 32),

            // --- Filters and Export ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterDropdown(),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Export CSV'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // --- Payments Table (List View for Mobile) ---
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: filteredPayments.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(40.0),
                child: Center(child: Text('No payments found matching your criteria')),
              )
                  : Column(
                children: [
                  _buildTableHeader(),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredPayments.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) => _buildPaymentRow(filteredPayments[index]),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Showing ${filteredPayments.length} of ${payments.length} payments',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStatCard(String title, String value, Color color, BoxConstraints constraints) {
    double cardWidth = (constraints.maxWidth - 16) / 2 - 8; // Mobile 2-column feel
    if (constraints.maxWidth > 600) cardWidth = (constraints.maxWidth - 48) / 4;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: filterStatus,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All Payments')),
            DropdownMenuItem(value: 'success', child: Text('Successful')),
            DropdownMenuItem(value: 'pending', child: Text('Pending')),
            DropdownMenuItem(value: 'failed', child: Text('Failed')),
          ],
          onChanged: (val) => setState(() => filterStatus = val!),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: const Row(
        children: [
          Expanded(flex: 2, child: Text('User Details', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(Payment p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.userName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(DateFormat('MMM dd, yyyy').format(p.date), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Text('₹${p.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: _buildStatusBadge(p.status),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case 'success':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        icon = Icons.check_circle;
        break;
      case 'failed':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        icon = Icons.cancel;
        break;
      default:
        bgColor = Colors.amber[50]!;
        textColor = Colors.amber[800]!;
        icon = Icons.access_time_filled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status[0].toUpperCase() + status.substring(1),
            style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}