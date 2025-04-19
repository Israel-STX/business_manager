import 'dart:async';
import 'package:flutter/material.dart';
import '../db/firebase_helper.dart';
import '../models/client.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  ClientsScreenState createState() => ClientsScreenState();
}

class ClientsScreenState extends State<ClientsScreen> {
  List<Client> _clients = [];
  String? _expandedClientId;
  StreamSubscription? _clientSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToClients();
  }

  // listen to client updates from firestore
  void _startListeningToClients() {
    _clientSubscription = FirebaseHelper.listenToClients().listen((entries) {
      final clients = entries.map((e) => e.value.copyWith(id: e.key)).toList();
      clients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() => _clients = clients);
    });
  }

  // stop listening when screen is closed
  @override
  void dispose() {
    _clientSubscription?.cancel();
    super.dispose();
  }

  // save changes to a client and update any job that uses them
  Future<void> _saveClient(Client updatedClient) async {
    await FirebaseHelper.updateClient(updatedClient.id, updatedClient);

    // update all jobs using this client
    final jobs = await FirebaseHelper.getJobs();
    for (final job in jobs) {
      if (job.clientId == updatedClient.id) {
        final updatedJob = job.copyWith(
          clientName: updatedClient.name,
          clientPhone: updatedClient.phone,
        );
        await FirebaseHelper.updateJob(job.id!, updatedJob);
      }
    }

    setState(() => _expandedClientId = null);
  }

  // show popup asking if you’re sure before deleting a client
  Future<void> _deleteClientPrompt(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Deletion", style: TextStyle(color: Colors.black)),
        content: Text("Are you sure you want to delete ${client.name}?",
            style: const TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseHelper.deleteClient(client.id);
      setState(() => _expandedClientId = null);
    }
  }

  // show form to add a new client
 // this shows a popup dialog where you can type in a new client's info
void _showAddClientDialog() {
  // controllers to hold the user's input
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  // show the alert dialog
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Add New Client", style: TextStyle(color: Colors.black)),

      // input fields inside the dialog
      content: SingleChildScrollView(
        child: Column(
          children: [
            // name input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Client Name'),
            ),
            const SizedBox(height: 12),
            // phone input
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
            ),
            const SizedBox(height: 12),
            // address input
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
      ),

      // action buttons at the bottom of the dialog
      actions: [
        // close the dialog without saving
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.black)),
        ),

        // save the new client
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          onPressed: () async {
            // make sure the name isn't empty
            if (nameController.text.isEmpty) return;

            // create the new client object
            final newClient = Client(
              id: '', // firestore will generate this
              name: nameController.text,
              phone: phoneController.text,
              address: addressController.text,
              notes: '',
            );

            // save to firestore
            await FirebaseHelper.addClient(newClient);

            // close the dialog
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text("Add"),
        ),
      ],
    ),
  );
}

// this builds a card for each client and shows an edit form if it's expanded
Widget _buildClientCard(Client client) {
  // whether this card is currently expanded
  final isExpanded = _expandedClientId == client.id;

  // create text fields with the client's current info
  final nameController = TextEditingController(text: client.name);
  final phoneController = TextEditingController(text: client.phone ?? '');
  final addressController = TextEditingController(text: client.address ?? '');

  return Card(
    color: Theme.of(context).cardColor,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Column(
      children: [
        // top part of the card with name and info
        ListTile(
          title: Text(
            client.name,
            style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (client.phone != null && client.phone!.isNotEmpty)
                Text(client.phone!, style: const TextStyle(color: Colors.black)),
              if (client.address != null && client.address!.isNotEmpty)
                Text(client.address!, style: const TextStyle(color: Colors.black)),
            ],
          ),
          trailing: IconButton(
            // show edit or close icon
            icon: Icon(isExpanded ? Icons.close : Icons.edit, color: Colors.black),
            onPressed: () => setState(() => _expandedClientId = isExpanded ? null : client.id),
          ),
        ),

        // show editable fields if card is expanded
        if (isExpanded)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              children: [
                // editable name
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Client Name'),
                ),
                const SizedBox(height: 12),

                // editable phone
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                ),
                const SizedBox(height: 12),

                // editable address
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 20),

                // row of buttons: cancel, delete, save
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // close the editor
                    TextButton(
                      onPressed: () => setState(() => _expandedClientId = null),
                      child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                    ),

                    // delete this client
                    TextButton(
                      onPressed: () => _deleteClientPrompt(client),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),

                    const SizedBox(width: 8),

                    // save the edited client info
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      onPressed: () {
                        final updated = client.copyWith(
                          name: nameController.text,
                          phone: phoneController.text,
                          address: addressController.text,
                        );
                        _saveClient(updated);
                      },
                      child: const Text('Save', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
      ],
    ),
  );
}

  // builds the full screen layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients'), backgroundColor: Colors.black, elevation: 0),
      body: _clients.isEmpty
          ? const Center(child: Text("No clients added yet.", style: TextStyle(color: Colors.white70)))
          : ListView(children: _clients.map(_buildClientCard).toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
