import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
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

  // load all invoices from firestore
  void loadInvoices() async {
    final data = await FirebaseHelper.getInvoices();
    setState(() => invoices = data);
  }

  // load all jobs from firestore
  void loadJobs() async {
    final data = await FirebaseHelper.getJobs();
    setState(() => jobs = data);
  }

  // load all clients from firestore
  void loadClients() async {
    final data = await FirebaseHelper.getClients();
    setState(() => clients = data);
  }

  // launch email app
  void _sendEmail(Invoice invoice) async {
    final taxRate = 0.0825;
    final taxAmount = invoice.cost * taxRate;
    final total = invoice.cost + taxAmount;

    final body = '''
Hello ${invoice.clientName},

Here are the details of your invoice:

- Service: ${invoice.service}
- Subtotal: \$${invoice.cost.toStringAsFixed(2)}
- Tax (8.25%): \$${taxAmount.toStringAsFixed(2)}
- Total Due: \$${total.toStringAsFixed(2)}
- Due Date: ${invoice.paymentDue}

Thank you for choosing Biz Buddy!
''';

    final uri = Uri(
      scheme: 'mailto',
      path: invoice.clientEmail ?? '',
      query: Uri.encodeFull('subject=Invoice from Biz Buddy&body=$body'),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch email app')),
      );
    }
  }

  // builds the full screen
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
                  if (invoice.notes?.isNotEmpty ?? false)
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
                      // delete invoice
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.black),
                        onPressed: () async {
                          if (invoice.id != null) {
                            await FirebaseHelper.deleteInvoice(invoice.id!);
                            loadInvoices();
                          }
                        },
                      ),
                      // preview pdf
                      IconButton(
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                        onPressed: () async {
                          final filePath = await PdfHelper.generateInvoicePdf(invoice);
                          await OpenFile.open(filePath);
                        },
                      ),
                      // send email
                      IconButton(
                        icon: const Icon(Icons.email, color: Colors.black),
                        onPressed: () => _sendEmail(invoice),
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
          if (!mounted) return;
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
