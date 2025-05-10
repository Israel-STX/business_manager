import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../models/services.dart';
import '../db/firebase_helper.dart';
import '../theme.dart';

// widget that appears under a job card to let you edit it
class EditJobDropdown extends StatefulWidget {
  final Job job;
  final List<Client> clients;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const EditJobDropdown({
    super.key,
    required this.job,
    required this.clients,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditJobDropdown> createState() => _EditJobDropdownState();
}

class _EditJobDropdownState extends State<EditJobDropdown> {
  late String selectedClientId;
  Services? selectedService;
  late TextEditingController notesController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();

    // initialize with job values
    selectedClientId = widget.job.clientId;
    notesController = TextEditingController(text: widget.job.notes ?? '');
    selectedDate = DateFormat.yMMMd('en_US').parse(widget.job.date);
    selectedTime = TimeOfDay(
      hour: int.parse(widget.job.time.split(":")[0]),
      minute: int.parse(widget.job.time.split(":")[1].split(" ")[0]),
    );

    _loadInitialService();
  }

  // load the current service linked to this job
  Future<void> _loadInitialService() async {
    final service = await FirebaseHelper.getServiceById(widget.job.serviceId);
    setState(() {
      selectedService = service ?? Services(id: '', name: 'Unknown Service', durationMinutes: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // dropdown for client selection
          DropdownButtonFormField<String>(
            value: selectedClientId,
            decoration: const InputDecoration(
              labelText: 'Client',
              filled: true,
              fillColor: Colors.white,
            ),
            items: widget.clients.map((c) {
              return DropdownMenuItem(value: c.id, child: Text(c.name));
            }).toList(),
            onChanged: (value) => setState(() => selectedClientId = value ?? selectedClientId),
          ),
          const SizedBox(height: 12),

          // dropdown for service selection
          FutureBuilder<List<Services>>(
            future: FirebaseHelper.getServices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Text('Error loading services');
              }

              final availableServices = snapshot.data!;
              final currentService = availableServices.firstWhere(
                (s) => s.id == widget.job.serviceId,
                orElse: () => selectedService ?? Services(id: '', name: 'Unknown', durationMinutes: 0),
              );

              return DropdownButtonFormField<Services>(
                value: selectedService ?? currentService,
                decoration: const InputDecoration(
                  labelText: 'Service',
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: availableServices.map((s) {
                  return DropdownMenuItem(value: s, child: Text(s.name));
                }).toList(),
                onChanged: (value) => setState(() => selectedService = value),
              );
            },
          ),
          const SizedBox(height: 12),

          // notes input
          TextFormField(
            controller: notesController,
            decoration: const InputDecoration(labelText: 'Notes', filled: true),
          ),
          const SizedBox(height: 12),

          // date picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Date: ${DateFormat.yMMMd().format(selectedDate)}"),
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    builder: (context, child) => AppThemes.datePickerTheme(context, child),
                  );
                  if (picked != null) setState(() => selectedDate = picked);
                },
              ),
            ],
          ),

          // time picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Time: ${selectedTime.format(context)}"),
              IconButton(
                icon: const Icon(Icons.access_time),
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                    builder: (context, child) => AppThemes.timePickerTheme(context, child),
                  );
                  if (picked != null) setState(() => selectedTime = picked);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // action buttons: cancel, delete, save
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
              TextButton(
                onPressed: () async {
                  await FirebaseHelper.deleteJob(widget.job.id!);
                  widget.onSave();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (selectedService == null) return;

                  final client = widget.clients.firstWhere(
                    (c) => c.id == selectedClientId,
                    orElse: () => Client(id: '', name: 'Unknown'),
                  );

                  final updated = widget.job.copyWith(
                    clientId: client.id,
                    clientName: client.name,
                    clientPhone: client.phone,
                    jobName: selectedService!.name,
                    serviceId: selectedService!.id,
                    date: DateFormat.yMMMd('en_US').format(selectedDate),
                    time: selectedTime.format(context),
                    notes: notesController.text.trim(),
                  );

                  await FirebaseHelper.updateJob(widget.job.id!, updated);
                  widget.onSave();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
