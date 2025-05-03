import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../models/services.dart';
import '../db/firebase_helper.dart';
import '../theme.dart';

// this widget shows the job editor dropdown under a job card
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
  Services? selectedService; // Make it nullable initially
  late TextEditingController notesController;
  late DateTime selectedDate;
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();

    selectedClientId = widget.job.clientId;
    notesController = TextEditingController(text: widget.job.notes ?? '');
    selectedDate = DateFormat.yMMMd('en_US').parse(widget.job.date);
    selectedTime = TimeOfDay(
      hour: int.parse(widget.job.time.split(":")[0]),
      minute: int.parse(widget.job.time.split(":")[1].split(" ")[0]),
    );

    _loadInitialService();
  }

  Future<void> _loadInitialService() async {
    if (widget.job.serviceId != null) {
      final service = await FirebaseHelper.getServiceById(widget.job.serviceId!);
      if (service != null) {
        setState(() {
          selectedService = service;
        });
      } else {
        // Handle the case where the serviceId in the job is invalid
        setState(() {
          selectedService = Services(id: '', name: 'Unknown Service', durationMinutes: 0);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        children: [
          // pick a client
          DropdownButtonFormField<String>(
            value: selectedClientId,
            decoration: const InputDecoration(
              labelText: 'Client',
              filled: true,
              fillColor: Colors.white,
            ),
            dropdownColor: Colors.white,
            style: const TextStyle(color: Colors.black),
            items: widget.clients
                .map((c) => DropdownMenuItem<String>(
              value: c.id,
              child: Text(c.name, style: const TextStyle(color: Colors.black)),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedClientId = value;
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // pick a service
          FutureBuilder<List<Services>>(
            future: FirebaseHelper.getServices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Loading indicator
              }
              if (snapshot.hasError) {
                return Text('Error loading services: ${snapshot.error}');
              }
              final availableServices = snapshot.data!;

              Services? initialSelectedService;
              if (widget.job.serviceId != null) {
                initialSelectedService = availableServices.firstWhere(
                      (s) => s.id == widget.job.serviceId,
                  orElse: () => Services(id: '', name: 'Unknown Service', durationMinutes: 0),
                );
              }

              return DropdownButtonFormField<Services>(
                value: initialSelectedService ?? selectedService,
                decoration: const InputDecoration(
                  labelText: 'Service',
                  filled: true,
                  fillColor: Colors.white,
                ),
                dropdownColor: Colors.white,
                style: const TextStyle(color: Colors.black),
                items: availableServices
                    .map((s) => DropdownMenuItem<Services>(
                  value: s,
                  child: Text(s.name, style: const TextStyle(color: Colors.black)),
                ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => selectedService = value);
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // notes
          TextFormField(
            controller: notesController,
            decoration: const InputDecoration(labelText: 'Notes', filled: true),
          ),
          const SizedBox(height: 12),

          // pick a date
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
          // pick a time
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

          // buttons to cancel, delete, or save the job
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // cancel and close editor
              TextButton(
                onPressed: widget.onCancel,
                child: const Text('Cancel'),
              ),
              // delete the job from firestore
              TextButton(
                onPressed: () async {
                  await FirebaseHelper.deleteJob(widget.job.id!);
                  widget.onSave();
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(width: 8),
              // save the job with new info
              ElevatedButton(
                onPressed: () async {
                  if (selectedService == null) return;

                  // find the selected client object
                  final selectedClient = widget.clients.firstWhere(
                        (c) => c.id == selectedClientId,
                    orElse: () => Client(id: '', name: 'Unknown'),
                  );

                  // make a new job with updated info, including serviceId
                  final updated = widget.job.copyWith(
                    clientId: selectedClient.id,
                    clientName: selectedClient.name,
                    clientPhone: selectedClient.phone,
                    jobName: selectedService!.name,
                    serviceId: selectedService!.id!,
                    date: DateFormat.yMMMd('en_US').format(selectedDate),
                    time: selectedTime.format(context),
                    notes: notesController.text.trim(),
                  );

                  // update job in firestore
                  await FirebaseHelper.updateJob(widget.job.id!, updated);

                  // close the dropdown
                  widget.onSave();
                },
                child: const Text('Save'),
              ),
            ],
          )
        ],
      ),
    );
  }
}