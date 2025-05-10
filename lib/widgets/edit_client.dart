import 'package:flutter/material.dart';
import '../models/client.dart';

// widget to edit a client's info
class EditClientForm extends StatelessWidget {
  // client to edit
  final Client client;

  // callback for canceling the edit
  final VoidCallback onCancel;

  // callback for deleting the client
  final VoidCallback onDelete;

  // callback for saving the updated client
  final Function(Client updated) onSave;

  const EditClientForm({
    super.key,
    required this.client,
    required this.onCancel,
    required this.onDelete,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    // controllers for input fields
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phone ?? '');
    final addressController = TextEditingController(text: client.address ?? '');
    final emailController = TextEditingController(text: client.email ?? '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          // name input
          TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Client Name')),
          const SizedBox(height: 12),

          // phone input
          TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
          const SizedBox(height: 12),

          // address input
          TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
          const SizedBox(height: 12),

          // email input
          TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 20),

          // action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // cancel button
              TextButton(
                onPressed: onCancel,
                child: const Text('Cancel', style: TextStyle(color: Colors.black)),
              ),

              // delete button
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),

              const SizedBox(width: 8),

              // save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                onPressed: () {
                  // build updated client
                  final updated = client.copyWith(
                    name: nameController.text,
                    phone: phoneController.text,
                    address: addressController.text,
                    email: emailController.text,
                  );

                  // call save callback
                  onSave(updated);
                },
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
