import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../models/services.dart';
import '../db/firebase_helper.dart';
import '../theme.dart';

// shows a popup form to create a new job
Future<void> showCreateJobDialog({
  required BuildContext context,
  required List<Client> clients,
  required List<Services> services,
}) async {
  // selected values
  Client? selectedClient;
  Services? selectedService;

  // default to current date and time
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // controller for notes input
  final notesController = TextEditingController();

  // build the dialog
  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Theme.of(context).cardColor,
            title: const Text("Create Job"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // dropdown for selecting client
                  DropdownButtonFormField<Client>(
                    decoration: const InputDecoration(labelText: "Select Client"),
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

                  // dropdown for selecting service
                  DropdownButtonFormField<Services>(
                    decoration: const InputDecoration(labelText: "Select Service"),
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

                  // input for optional notes
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: "Notes"),
                  ),
                  const SizedBox(height: 12),

                  // row for selecting date
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
                          if (picked != null) setDialogState(() => selectedDate = picked);
                        },
                      ),
                    ],
                  ),

                  // row for selecting time
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
                          if (picked != null) setDialogState(() => selectedTime = picked);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // dialog buttons
            actions: [
              // cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.red)),
              ),

              // add job button
              TextButton(
                onPressed: () async {
                  // don't proceed without required fields
                  if (selectedClient == null || selectedService == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a client and a service.')),
                      );
                    }
                    return;
                  }

                  final client = selectedClient!;
                  final service = selectedService!;

                  // format selected date and time
                  final formattedDate = DateFormat.yMMMd('en_US').format(selectedDate);
                  // final formattedTime = selectedTime.format(context);

                  // convert selected time to minutes for conflict checking
                  final newJobStartTimeInMinutes = selectedTime.hour * 60 + selectedTime.minute;
                  final newJobEndTimeInMinutes = newJobStartTimeInMinutes + service.durationMinutes;

                  // get all jobs on selected date
                  List<Job> existingJobsOnDate;
                  try {
                    existingJobsOnDate = await FirebaseHelper.getJobsByDate(formattedDate);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error fetching existing jobs: $e')),
                      );
                    }
                    return;
                  }

                  bool hasConflict = false;

                  for (final existingJob in existingJobsOnDate) {
                    Services? existingJobService;
                    try {
                      if (existingJob.serviceId.isNotEmpty) {
                        existingJobService = await FirebaseHelper.getServiceById(existingJob.serviceId);
                      } else {
                        print("Skipping conflict check for existing job ${existingJob.id} due to missing serviceId.");
                        continue;
                      }
                    } catch (e) {
                      print("Error fetching service for existing job ${existingJob.id} during conflict check: $e");
                      continue;
                    }

                    if (existingJobService != null) {
                      DateTime parsedExistingJobTime;
                      try {
                        parsedExistingJobTime = DateFormat("h:mm a").parse(existingJob.time);
                      } catch (e) {
                        print("Error parsing time for existing job ${existingJob.id} ('${existingJob.time}'): $e. Skipping for conflict check.");
                        continue; // Skip if time format is wrong
                      }

                      final existingJobStartTimeInMinutes = parsedExistingJobTime.hour * 60 + parsedExistingJobTime.minute;
                      final existingJobEndTimeInMinutes = existingJobStartTimeInMinutes + existingJobService.durationMinutes;

                      if (newJobStartTimeInMinutes < existingJobEndTimeInMinutes && newJobEndTimeInMinutes > existingJobStartTimeInMinutes) {
                        hasConflict = true;
                        break;
                      }
                    }
                  }

                  // show error if conflict exists
                  if (hasConflict) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('The selected time directly overlaps with an existing job.'),
                        ),
                      );
                    }
                  } else {
                    // create and save new job
                    final newJob = Job(
                      clientId: client.id,
                      clientName: client.name,
                      clientPhone: client.phone,
                      jobName: service.name,
                      date: formattedDate, // Use the 'en_US' formatted date for storage
                      time: selectedTime.format(context), // Use locale-aware time format for storage/display
                      notes: notesController.text.trim(),
                      serviceId: service.id,
                    );

                    try {
                      await FirebaseHelper.addJob(newJob);
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add job: $e')),
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
