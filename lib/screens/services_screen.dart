import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/services.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Services> services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final types = await DatabaseHelper.instance.getServices();
    setState(() {
      services = types;
    });
  }

  void _showServiceDialog({Services? service}) {
    final isEditing = service != null;
    final nameController = TextEditingController(text: service?.name ?? "");
    final durationController = TextEditingController(
      text: service?.durationMinutes.toString() ?? "",
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isEditing ? 'Edit Service' : 'Add Service'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
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

                  if (isEditing) {
                    await DatabaseHelper.instance.updateServices(
                      service.copyWith(name: name, durationMinutes: duration),
                    );
                  } else {
                    await DatabaseHelper.instance.addService(
                      Services(name: name, durationMinutes: duration),
                    );
                  }

                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadServices();
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteService(int id) async {
    await DatabaseHelper.instance.deleteServices(id);
    _loadServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (context, index) {
          final type = services[index];
          return ListTile(
            title: Text(type.name),
            subtitle: Text('${type.durationMinutes} minutes'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () => _showServiceDialog(service: type),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteService(type.id!),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showServiceDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
