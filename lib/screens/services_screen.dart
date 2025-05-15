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
  // all services from firestore
  List<MapEntry<String, Services>> services = [];

  // expanded service id
  String? _expandedId;

  // stream to stop later
  StreamSubscription? _serviceSub;

  @override
  void initState() {
    super.initState();
    _serviceSub = FirebaseHelper.listenToServices().listen((data) {
      setState(() => services = data);
    });
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    super.dispose();
  }

  // open dialog to add service
  void _showAddServiceDialog() {
    final nameCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Add New Service"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Service Name')),
            const SizedBox(height: 12),
            TextField(
              controller: durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Duration (minutes)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              final duration = int.tryParse(durationCtrl.text.trim()) ?? 0;
              if (name.isEmpty || duration <= 0) return;

              await FirebaseHelper.addService(Services(id: '', name: name, durationMinutes: duration));
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _attemptDeleteService(String id, Services service) async {

    bool isUsed = false;
    try {
      isUsed = await FirebaseHelper.isServiceInUse(id);
    } catch (e) {
      // check fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not verify service usage. Please try again. Error: $e')),
        );
      }
      return;
    }

    if (!mounted) return;

    if (isUsed) {
      // popup if service is in use
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text("Cannot Delete Service"),
          content: Text("${service.name} is currently assigned to one or more jobs. Please remove it from all jobs before deleting, or consider editing the service if an update is needed."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Service is not in use
      _showActualDeleteConfirmationDialog(id, service);
    }
  }

  void _showActualDeleteConfirmationDialog(String id, Services service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: const Text("Confirm Deletion"),
        content: Text("Are you sure you want to delete ${service.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              try {
                await FirebaseHelper.deleteService(id);
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${service.name} deleted successfully.')),
                  );
                }
              } catch (e) {
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete ${service.name}: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  // single service card with edit view
  Widget _buildServiceCard(MapEntry<String, Services> entry) {
    final id = entry.key;
    final service = entry.value;
    final isExpanded = _expandedId == id;

    final nameCtrl = TextEditingController(text: service.name);
    final durationCtrl = TextEditingController(text: service.durationMinutes.toString());

    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          ListTile(
            title: Text(service.name, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Text('${service.durationMinutes} minutes'),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.close : Icons.edit, color: Colors.black),
              onPressed: () => setState(() => _expandedId = isExpanded ? null : id),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: Column(
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Service Name')),
                  const SizedBox(height: 12),
                  TextField(
                    controller: durationCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => setState(() => _expandedId = null), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () => _attemptDeleteService(id, service),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final duration = int.tryParse(durationCtrl.text.trim()) ?? 0;
                          if (name.isEmpty || duration <= 0) return;

                          final updated = Services(id: '', name: name, durationMinutes: duration);
                          await FirebaseHelper.updateService(id, updated);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: services.isEmpty
          ? const Center(child: Text("No services available."))
          : ListView(children: services.map(_buildServiceCard).toList()),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddServiceDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
