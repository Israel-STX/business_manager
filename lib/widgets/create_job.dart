import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../models/services.dart';
import '../db/firebase_helper.dart';
import '../theme.dart';

// this shows a popup form to create a new job
Future<void> showCreateJobDialog({
  required BuildContext context,
  required List<Client> clients,
  required List<Services> services,
}) async {
  // store selected values and text input
  Client? selectedClient;
  Services? selectedService;
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  final notesController = TextEditingController();

  // show the actual dialog
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text("Create Job"),

            // job form inputs
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // dropdown to select a client
                  DropdownButtonFormField<Client>(
                    decoration: const InputDecoration(
                      labelText: "Select Client",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    value: selectedClient,
                    items: clients.map((client) {
                      return DropdownMenuItem(
                        value: client,
                        child: Text(client.name, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) => setDialogState(() => selectedClient = value),
                  ),
                  const SizedBox(height: 10),

                  // dropdown to select a service
                  DropdownButtonFormField<Services>(
                    decoration: const InputDecoration(
                      labelText: "Select Service",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black),
                    value: selectedService,
                    items: services.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.name, style: const TextStyle(color: Colors.black)),
                      );
                    }).toList(),
                    onChanged: (value) => setDialogState(() => selectedService = value),
                  ),
                  const SizedBox(height: 10),

                  // text field to type in notes
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: "Notes"),
                  ),
                  const SizedBox(height: 12),

                  // row to pick a date
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
                          if (picked != null) {
                            setDialogState(() => selectedDate = picked);
                          }
                        },
                      ),
                    ],
                  ),

                  // row to pick a time
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
                          if (picked != null) {
                            setDialogState(() => selectedTime = picked);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // buttons at the bottom of the popup
            actions: [
              // close without saving
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),

              // save the job
              TextButton(
                onPressed: () async {
                  // make sure both client and service are selected
                  if (selectedClient == null || selectedService == null) return;

                  // create a new job object
                  final newJob = Job(
                    clientId: selectedClient!.id,
                    clientName: selectedClient!.name,
                    clientPhone: selectedClient!.phone,
                    jobName: selectedService!.name,
                    date: DateFormat.yMMMd('en_US').format(selectedDate),
                    time: selectedTime.format(context),
                    notes: notesController.text.trim(),
                  );

                  // add job to firestore
                  await FirebaseHelper.addJob(newJob);

                  // close the dialog if still on screen
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text("Add Job"),
              ),
            ],
          );
        },
      );
    },
  );
}
