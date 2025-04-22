import 'package:flutter/material.dart';
import '../db/firebase_helper.dart';
import '../models/invoice.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../widgets/pdf_maker.dart';
import '../widgets/create_invoice.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({super.key});

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  List<Invoice> invoices = [];
  List<Job> jobs = [];
  List<Client> clients = [];

  @override
  void initState() {
    super.initState();
    loadInvoices();
    loadJobs();
    loadClients();
  }

  void loadInvoices() async {
    final data = await FirebaseHelper.getInvoices();
    setState(() => invoices = data);
  }

  void loadJobs() async {
    final data = await FirebaseHelper.getJobs();
    setState(() => jobs = data);
  }

  void loadClients() async {
    final data = await FirebaseHelper.getClients();
    setState(() => clients = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoices')),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: invoices.length,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(invoice.clientName, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(invoice.clientAddress),
                  Text(invoice.clientPhone),
                  const Divider(height: 20),
                  Text("Service: ${invoice.service}"),
                  if (invoice.notes != null && invoice.notes!.isNotEmpty)
                    Text("Notes: ${invoice.notes}"),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Cost: \$${invoice.cost.toStringAsFixed(2)}"),
                      Text("Due: ${invoice.paymentDue}"),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          if (invoice.id != null) {
                            await FirebaseHelper.deleteInvoice(invoice.id!);
                            loadInvoices();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.email, color: Colors.blue),
                        onPressed: () => PdfHelper.generateInvoicePdf(invoice),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final jobs = await FirebaseHelper.getJobs();
          showCreateInvoiceDialog(
            context: context,
            jobs: jobs,
            clients: clients,
            onSave: loadInvoices,
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
