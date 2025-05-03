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
                child: const Text("Cancel", style: TextStyle(color: Colors.red))),
              TextButton(
                onPressed: () async {
                  print("Attempting to add a new job...");
                  if (selectedClient == null || selectedService == null) {
                    print("Error: selectedClient or selectedService is null. Aborting job creation.");
                    return;
                  }

                  String formattedDate = DateFormat.yMMMd('en_US').format(selectedDate);
                  String formattedTime = selectedTime.format(context);

                  print("Selected Client ID: ${selectedClient!.id}");
                  print("Selected Service ID: ${selectedService!.id}");
                  print("Formatted Date: $formattedDate");
                  print("Formatted Time: $formattedTime");
                  print("Notes: ${notesController.text.trim()}");

                  int newJobStartTimeMinutes = selectedTime.hour * 60 + selectedTime.minute;
                  int newJobEndTimeMinutes = newJobStartTimeMinutes + selectedService!.durationMinutes;

                  List<Job> existingJobsOnDate = await FirebaseHelper.getJobsByDate(formattedDate);
                  bool hasConflict = false;

                  for (final existingJob in existingJobsOnDate) {

                    final existingJobService = await FirebaseHelper.getServiceById(existingJob.serviceId!);

                    if (existingJobService != null) {
                      DateFormat timeFormat = DateFormat("h:mm a");
                      DateTime existingJobStartTimeDateTime = timeFormat.parse(existingJob.time);
                      int existingJobStartTimeMinutes = existingJobStartTimeDateTime.hour * 60 + existingJobStartTimeDateTime.minute;
                      int existingJobEndTimeMinutesWithBuffer = existingJobStartTimeMinutes + existingJobService.durationMinutes + 30; // Add 30 min buffer to end

                      // Calculate the new job's interval with a 30 min buffer at the start
                      int newJobStartTimeMinutesWithBuffer = newJobStartTimeMinutes - 30;
                      if (newJobStartTimeMinutesWithBuffer < 0) newJobStartTimeMinutesWithBuffer = 0; // Prevent negative start time

                      // Check for overlaps with the existing job's interval (including its end buffer)
                      if (newJobStartTimeMinutesWithBuffer < existingJobEndTimeMinutesWithBuffer &&
                          newJobEndTimeMinutes > existingJobStartTimeMinutes) {
                        hasConflict = true;
                        break;
                      }
                    }
                  }

                  if (hasConflict) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('The selected time slot overlaps with an existing job (including travel time).')),
                      );
                    }
                  } else {
                    final newJob = Job(
                      clientId: selectedClient!.id,
                      clientName: selectedClient!.name,
                      clientPhone: selectedClient!.phone,
                      jobName: selectedService!.name,
                      date: formattedDate,
                      time: formattedTime,
                      notes: notesController.text.trim(),
                      serviceId: selectedService!.id!,
                    );
                    print("Attempting to add job to Firestore: ${newJob.toMap()}");
                    try {
                      await FirebaseHelper.addJob(newJob);
                      print("Job added successfully to Firestore.");
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      print("Error adding job to Firestore: $e");
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add job. Error: $e')),
                        );
                      }
                    }
                  }
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