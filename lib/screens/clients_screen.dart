import 'dart:async';
import 'package:flutter/material.dart';
import '../db/firebase_helper.dart';
import '../models/client.dart';
import '../widgets/add_client.dart';
import '../widgets/edit_client.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  ClientsScreenState createState() => ClientsScreenState();
}

class ClientsScreenState extends State<ClientsScreen> {
  // holds all clients from firestore
  List<Client> _clients = [];

  // tracks which client is currently expanded
  String? _expandedClientId;

  // listener for client updates
  StreamSubscription? _clientSubscription;

  @override
  void initState() {
    super.initState();
    _startListeningToClients();
  }

  // listen to firestore for live client updates
  void _startListeningToClients() {
    _clientSubscription = FirebaseHelper.listenToClients().listen((entries) {
      final clients = entries.map((e) => e.value.copyWith(id: e.key)).toList();
      clients.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() => _clients = clients);
    });
  }

  // stop listening when widget is removed
  @override
  void dispose() {
    _clientSubscription?.cancel();
    super.dispose();
  }

  // save updated client and update all related jobs
  Future<void> _saveClient(Client updatedClient) async {
    await FirebaseHelper.updateClient(updatedClient.id, updatedClient);

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

  // confirm and delete a client and their jobs
  Future<void> _deleteClientPrompt(Client client) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Confirm Deletion", style: TextStyle(color: Colors.black)),
        content: Text(
          "Are you sure you want to delete ${client.name}? All jobs with this client will also be deleted.",
          style: const TextStyle(color: Colors.black),
        ),
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
      try {
        final jobs = await FirebaseHelper.getJobsByClientId(client.id);
        for (final doc in jobs.docs) {
          await FirebaseHelper.deleteJob(doc.id);
        }
        await FirebaseHelper.deleteClient(client.id);
        if (mounted) setState(() => _expandedClientId = null);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting client and associated jobs: $error')),
          );
        }
      }
    }
  }

  // open dialog to add a new client
  void _showAddClientDialog() {
    showDialog(
      context: context,
      builder: (context) => AddClientDialog(
        onClientAdded: () {
          if (mounted) Navigator.pop(context);
        },
      ),
    );
  }

  // build one client card with info and edit form
  Widget _buildClientCard(Client client) {
    final isExpanded = _expandedClientId == client.id;

    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // client details
          ListTile(
            title: Text(
              client.name,
              style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (client.phone?.isNotEmpty ?? false)
                  Text(client.phone!, style: const TextStyle(color: Colors.black)),
                if (client.address?.isNotEmpty ?? false)
                  Text(client.address!, style: const TextStyle(color: Colors.black)),
                if (client.email?.isNotEmpty ?? false)
                  Text(client.email!, style: const TextStyle(color: Colors.black)),
              ],
            ),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.close : Icons.edit, color: Colors.black),
              onPressed: () => setState(() => _expandedClientId = isExpanded ? null : client.id),
            ),
          ),

          // if expanded, show the editor widget
          if (isExpanded)
            EditClientForm(
              client: client,
              onCancel: () => setState(() => _expandedClientId = null),
              onDelete: () => _deleteClientPrompt(client),
              onSave: _saveClient,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _clients.isEmpty
          ? const Center(
              child: Text("No clients added yet.", style: TextStyle(color: Colors.white70)),
            )
          : ListView(
              children: _clients.map(_buildClientCard).toList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClientDialog,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
