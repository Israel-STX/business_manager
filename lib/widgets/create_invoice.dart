import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../db/firebase_helper.dart';

void showCreateInvoiceDialog({
  required BuildContext context,
  required List<Job> jobs,
  required List<Client> clients,
  required VoidCallback onSave,
}) {
  Job? selectedJob;
  final costController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text('Create Invoice from Job'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Job>(
                decoration: const InputDecoration(labelText: 'Select Job'),
                value: selectedJob,
                items: jobs.map((job) {
                  return DropdownMenuItem(
                    value: job,
                    child: Text('${job.jobName} - ${job.clientName ?? "Unknown"}'),
                  );
                }).toList(),
                onChanged: (job) => setState(() => selectedJob = job),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Service Cost'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (selectedJob == null || costController.text.trim().isEmpty) return;

                final client = clients.firstWhere(
                  (c) => c.id == selectedJob!.clientId,
                  orElse: () => Client(id: '', name: '', phone: '', address: '', notes: ''),
                );

                final invoice = Invoice(
                  clientName: client.name,
                  clientAddress: client.address ?? '',
                  clientPhone: client.phone ?? '',
                  service: selectedJob!.jobName,
                  notes: selectedJob!.notes,
                  cost: double.tryParse(costController.text.trim()) ?? 0.0,
                  paymentDue: selectedJob!.date,
                );

                await FirebaseHelper.addInvoice(invoice);
                if (context.mounted) Navigator.pop(context);
                onSave();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    ),
  );
}
