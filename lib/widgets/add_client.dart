import 'package:flutter/material.dart';
import '../db/firebase_helper.dart';
import '../models/client.dart';

// popup widget to handle adding a new client
class AddClientDialog extends StatelessWidget {
  // callback to refresh after adding
  final VoidCallback onClientAdded;

  const AddClientDialog({super.key, required this.onClientAdded});

  @override
  Widget build(BuildContext context) {
    // form controllers
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final emailController = TextEditingController();

    return AlertDialog(
      backgroundColor: Colors.white,

      // title
      title: const Text("Add New Client", style: TextStyle(color: Colors.black)),

      // form content
      content: SingleChildScrollView(
        child: Column(
          children: [
            // name field
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Client Name')),
            const SizedBox(height: 12),

            // phone field
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),
            const SizedBox(height: 12),

            // address field
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
            const SizedBox(height: 12),

            // email field
            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
          ],
        ),
      ),

      // action buttons
      actions: [
        // cancel button
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.black)),
        ),

        // add button
        TextButton(
          onPressed: () async {
            if (nameController.text.isEmpty) return;

            // create new client
            final newClient = Client(
              id: '',
              name: nameController.text,
              phone: phoneController.text,
              address: addressController.text,
              email: emailController.text,
              notes: '',
            );

            // save to firestore
            await FirebaseHelper.addClient(newClient);

            // notify parent
            onClientAdded();
          },
          child: const Text("Add"),
        ),
      ],
    );
  }
}
