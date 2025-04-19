import 'dart:async';
import 'package:flutter/material.dart';
import '../models/services.dart';
import '../db/firebase_helper.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  // list of services from firestore
  List<MapEntry<String, Services>> services = [];

  // keeps track of which service is expanded
  String? _expandedId;

  // to stop the stream later
  StreamSubscription? _serviceSub;

  @override
  void initState() {
    super.initState();
    _startListeningToServices();
  }

  // this listens to changes in firestore services collection
  void _startListeningToServices() {
    _serviceSub = FirebaseHelper.listenToServices().listen((data) {
      setState(() {
        services = data;
      });
    });
  }

  // stop listening when screen is destroyed
  @override
  void dispose() {
    _serviceSub?.cancel();
    super.dispose();
  }

  // opens a popup to add a new service
  void _showAddServiceDialog() {
    final nameController = TextEditingController();
    final durationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Add New Service"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              // text box for service name
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              const SizedBox(height: 12),

              // text box for duration
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final duration = int.tryParse(durationController.text.trim()) ?? 0;
              if (name.isEmpty || duration <= 0) return;

              final newService = Services(name: name, durationMinutes: duration);
              await FirebaseHelper.addService(newService);

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  // asks before deleting a service
  void _confirmDelete(String docId, Services service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete ${service.name}?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseHelper.deleteService(docId);
              if (context.mounted) Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // shows a single service card
  Widget _buildServiceCard(MapEntry<String, Services> entry) {
    final docId = entry.key;
    final service = entry.value;
    final isExpanded = _expandedId == docId;

    // form controllers for edits
    final nameController = TextEditingController(text: service.name);
    final durationController = TextEditingController(text: service.durationMinutes.toString());

    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // regular view
          ListTile(
            title: Text(service.name, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text('${service.durationMinutes} minutes', style: Theme.of(context).textTheme.bodyMedium),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.close : Icons.edit, color: Theme.of(context).iconTheme.color),
              onPressed: () {
                setState(() {
                  _expandedId = isExpanded ? null : docId;
                });
              },
            ),
          ),

          // editing form when expanded
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Service Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // cancel button
                      TextButton(
                        onPressed: () => setState(() => _expandedId = null),
                        child: const Text('Cancel'),
                      ),

                      // delete button
                      TextButton(
                        onPressed: () => _confirmDelete(docId, service),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                      const SizedBox(width: 8),

                      // save button
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameController.text.trim();
                          final duration = int.tryParse(durationController.text.trim()) ?? 0;
                          if (name.isEmpty || duration <= 0) return;

                          final updated = Services(name: name, durationMinutes: duration);
                          await FirebaseHelper.updateService(docId, updated);
                          setState(() => _expandedId = null);
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // puts everything on the screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),

      // show message or list
      body: services.isEmpty
          ? const Center(child: Text("No services available."))
          : ListView(children: services.map(_buildServiceCard).toList()),

      // button to add a service
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
