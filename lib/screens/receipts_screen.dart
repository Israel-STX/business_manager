import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/receipt.dart';

class ReceiptsScreen extends StatefulWidget {
  const ReceiptsScreen({super.key});

  @override
  State<ReceiptsScreen> createState() => _ReceiptsScreenState();
}

class _ReceiptsScreenState extends State<ReceiptsScreen> {
  List<Receipt> receipt = [];

  @override
  void initState() {
    super.initState();
    loadReceipts();
  }

  void showReceiptPreview() {
    //TODO: need to create a preview screen from the receipt
  }
  void loadReceipts() {
    //TODO: need to load in all the receipts.
  }

  void emailReceipt() {
    //TODO: set up to send email.
  }

  void createManualReceipt(receipt) {
    final nameController = TextEditingController(
      text: receipt?.invoiceId ?? "",
    );
    final durationController = TextEditingController(
      text: receipt?.durationMinutes.toString() ?? "",
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Service Name'),
                ),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Duration (minutes)',
                  ),
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
                  final name = nameController.text.trim();
                  final duration =
                      int.tryParse(durationController.text.trim()) ?? 0;
                  if (name.isEmpty || duration <= 0) return;

                  if (context.mounted) {
                    Navigator.pop(context);
                    loadReceipts();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receipts')),
      body: ListView.builder(
        itemCount: receipt.length,
        itemBuilder: (context, index) {
          final type = receipt[index];
          return ListTile(
            title: Text(type.jobName),
            subtitle: Text('${type.clientId}  ${type.date}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => showReceiptPreview(),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => emailReceipt(),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => createManualReceipt(receipt[0]),
        child: const Icon(Icons.add),
      ),
    );
  }
}
