import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/client.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  ClientsScreenState createState() => ClientsScreenState();
}

class ClientsScreenState extends State<ClientsScreen> {
  //final TextEditingController _searchController = TextEditingController();
  List<Client> _clients = [];

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clients = await DatabaseHelper.instance.getClients();
    clients.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    setState(() {
      _clients = clients;
    });
  }

  void _showClientDialog({Client? client}) {
    TextEditingController nameController = TextEditingController(
      text: client?.name ?? '',
    );
    TextEditingController addressController = TextEditingController(
      text: client?.address ?? '',
    );
    TextEditingController phoneController = TextEditingController(
      text: client?.phone ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(client == null ? 'Add Client' : 'Edit Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Client Name"),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: "Address"),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: "Phone Number"),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            if (client != null)
              TextButton(
                onPressed: () {
                  _showDeleteConfirmation(client);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('Delete'),
              ),
            TextButton(
              onPressed: () async {
                if (nameController.text.isEmpty) return;
                final newClient = Client(
                  id: client?.id,
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                  notes: "",
                );
                if (client == null) {
                  await DatabaseHelper.instance.addClient(newClient);
                } else {
                  await DatabaseHelper.instance.updateClient(newClient);
                }

                if (context.mounted) {
                  _loadClients();
                  Navigator.pop(context);
                }
              },
              child: Text(client == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(Client client) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete ${client.name}?"),
          actions: [
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteClient(client.id!);

                if (context.mounted) {
                  _loadClients();
                  Navigator.pop(context);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body:
          _clients.isEmpty
              ? const Center(child: Text("No clients added yet."))
              : ListView.builder(
                itemCount: _clients.length,
                itemBuilder: (context, index) {
                  final client = _clients[index];
                  return ListTile(
                    title: Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(client.phone ?? "No phone"),
                    onTap: () => _showClientDialog(client: client),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClientDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
