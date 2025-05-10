import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../models/invoice.dart';
import '../db/firebase_helper.dart';

// shows a popup to create an invoice based on an existing job
void showCreateInvoiceDialog({
  required BuildContext context,
  required List<Job> jobs,
  required List<Client> clients,
  required VoidCallback onSave,
}) {
  // stores selected job
  Job? selectedJob;

  // controller for invoice cost input
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
              // dropdown to pick a job
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

              // field for entering the invoice cost
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Service Cost'),
              ),
            ],
          ),
          actions: [
            // cancel button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),

            // save and create invoice button
            TextButton(
              onPressed: () async {
                // don't continue if job or cost is empty
                if (selectedJob == null || costController.text.trim().isEmpty) return;

                // get client for the selected job
                final client = clients.firstWhere(
                  (c) => c.id == selectedJob!.clientId,
                  orElse: () => Client(id: '', name: '', phone: '', address: '', notes: '', email: ''),
                );

                // build invoice object
                final invoice = Invoice(
                  clientName: client.name,
                  clientAddress: client.address ?? '',
                  clientPhone: client.phone ?? '',
                  clientEmail: client.email ?? '',
                  service: selectedJob!.jobName,
                  notes: selectedJob!.notes,
                  cost: double.tryParse(costController.text.trim()) ?? 0.0,
                  paymentDue: selectedJob!.date,
                );

                // save invoice to firestore
                await FirebaseHelper.addInvoice(invoice);

                // close the dialog and refresh the list
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
