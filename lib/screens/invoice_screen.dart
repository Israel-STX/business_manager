import 'package:flutter/material.dart';

// ignore this as it was just to have a invoice screen for the moment while partner works on his iteration
// uses all test data and basic code

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            Text(
              'Recent Invoices',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            _buildInvoiceCard(
              context,
              client: 'John Doe',
              date: 'Apr 10, 2025',
              amount: 75.00,
              status: 'Paid',
            ),
            _buildInvoiceCard(
              context,
              client: 'Jane Smith',
              date: 'Apr 12, 2025',
              amount: 60.00,
              status: 'Unpaid',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceCard(
    BuildContext context, {
    required String client,
    required String date,
    required double amount,
    required String status,
  }) {
    final isPaid = status == 'Paid';

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          isPaid ? Icons.check_circle : Icons.warning,
          color: isPaid ? Colors.green : Colors.red,
        ),
        title: Text(
          '$client - \$${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text('Date: $date'),
        trailing: Text(
          status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPaid ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
