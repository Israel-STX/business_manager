import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../db/database_helper.dart';
import '../models/client.dart';
import '../models/job.dart';
import '../models/services.dart';
import 'package:url_launcher/url_launcher.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  DateTime selectedDate = DateTime.now();
  List<Job> jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  void _launchMaps(int clientId) async {
    Client? client = await DatabaseHelper.instance.getClientById(clientId);
    if (client != null &&
        client.address != null &&
        client.address!.isNotEmpty) {
      final Uri url = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(client.address!)}",
      );
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        debugPrint("Could not launch $url");
      }
    } else {
      debugPrint("No address available for client ID $clientId");
    }
  }

  void _editJob(Job job) async {
    List<Client> clients = await DatabaseHelper.instance.getClients();
    Client? selectedClient = clients.firstWhere(
      (c) => c.id == job.clientId,
      orElse: () => clients.first,
    );

    TextEditingController notesController = TextEditingController(
      text: job.notes,
    );
    DateTime selectedJobDate;
    try {
      selectedJobDate = intl.DateFormat.yMMMd('en_US').parse(job.date);
    } catch (e) {
      debugPrint("Error parsing date: \${job.date}, Error: \$e");
      selectedJobDate = DateTime.now();
    }
    TimeOfDay selectedTime = TimeOfDay(
      hour: int.parse(job.time.split(":")[0]),
      minute: int.parse(job.time.split(":")[1].split(" ")[0]),
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Edit Job"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Client>(
                    decoration: const InputDecoration(
                      labelText: "Change Client",
                    ),
                    value: selectedClient,
                    items:
                        clients.map((client) {
                          return DropdownMenuItem(
                            value: client,
                            child: Text(client.name),
                          );
                        }).toList(),
                    onChanged: (Client? value) {
                      setDialogState(() {
                        selectedClient = value;
                      });
                    },
                  ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: "Notes (Optional)",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date: ${intl.DateFormat.yMMMd('en_US').format(selectedJobDate)}",
                      ),
                      IconButton(
                        key: Key('date_schedule'),
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedJobDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setDialogState(() {
                              selectedJobDate = pickedDate;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Time: ${selectedTime.format(dialogContext)}"),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: dialogContext,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            setDialogState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedClient == null) return;

                    await DatabaseHelper.instance.updateJob(
                      job.copyWith(
                        clientId: selectedClient!.id!,
                        date: intl.DateFormat.yMMMd(
                          'en_US',
                        ).format(selectedJobDate),
                        time: selectedTime.format(dialogContext),
                        notes: notesController.text,
                      ),
                    );
                    if (context.mounted) {
                      _loadJobs();
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text("Save Changes"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _cancelJob(int? jobId) async {
    if (jobId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Cancel Job"),
          content: const Text(
            "Are you sure you want to cancel this job? This action cannot be undone.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteJob(jobId);
                if (context.mounted) {
                  _loadJobs();
                  Navigator.pop(context);
                }
              },
              child: const Text("Yes, Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _addNotes(Job job) {
    TextEditingController notesController = TextEditingController(
      text: job.notes,
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Add Notes"),
          content: TextField(
            controller: notesController,
            maxLines: 1,
            decoration: const InputDecoration(labelText: "Enter notes"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseHelper.instance.updateJob(
                  job.copyWith(notes: notesController.text),
                );
                if (context.mounted) {
                  _loadJobs();
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text("Save Notes"),
            ),
          ],
        );
      },
    );
  }

  void _callClient(int clientId) async {
    Client? client = await DatabaseHelper.instance.getClientById(clientId);
    if (client != null && client.phone != null && client.phone!.isNotEmpty) {
      final Uri url = Uri.parse("tel:${client.phone}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        debugPrint("Could not launch $url");
      }
    } else {
      debugPrint("No phone number available for client ID $clientId");
    }
  }

  void _textClient(int clientId) async {
    Client? client = await DatabaseHelper.instance.getClientById(clientId);
    if (client != null && client.phone != null && client.phone!.isNotEmpty) {
      final Uri url = Uri.parse("sms:${client.phone}");
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        debugPrint("Could not launch $url");
      }
    } else {
      debugPrint("No phone number available for client ID $clientId");
    }
  }

  Future<void> _loadJobs() async {
    final allJobs = await DatabaseHelper.instance.getJobs();
    List<Job> updatedJobs = [];

    for (var job in allJobs) {
      Client? client = await DatabaseHelper.instance.getClientById(
        job.clientId,
      );
      updatedJobs.add(
        Job(
          id: job.id,
          clientId: job.clientId,
          date: job.date,
          time: job.time,
          status: job.status,
          jobName: job.jobName,
          notes: job.notes,
          clientName: client?.name ?? "Unknown Client",
        ),
      );
    }

    setState(() {
      jobs =
          updatedJobs
              .where((job) => job.date == _formatDate(selectedDate))
              .toList();
    });
  }

  String _formatDate(DateTime date) {
    return intl.DateFormat.yMMMd('en_US').format(date);
  }

  void _showAddJobDialog() async {
    List<Client> clients = await DatabaseHelper.instance.getClients();
    List<Services> services = await DatabaseHelper.instance.getServices();

    if (!mounted) return;
    if (clients.isEmpty) {
      _showNoClientsWarning();
      return;
    }
    if (services.isEmpty) {
      _showNoServicesWarning();
      return;
    }

    Client? selectedClient;
    Services? selectedJobType;
    TextEditingController notesController = TextEditingController();
    DateTime selectedJobDate = selectedDate;
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Add New Job"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<Client>(
                    decoration: const InputDecoration(
                      labelText: "Select Client",
                    ),
                    value: selectedClient,
                    items:
                        clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client,
                                child: Text(client.name),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) => setDialogState(() => selectedClient = value),
                  ),
                  DropdownButtonFormField<Services>(
                    decoration: const InputDecoration(
                      labelText: "Select Job Type",
                    ),
                    value: selectedJobType,
                    items:
                        services
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.name),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (value) =>
                            setDialogState(() => selectedJobType = value),
                  ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: "Notes (Optional)",
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date: ${intl.DateFormat.yMMMd('en_US').format(selectedJobDate)}",
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: dialogContext,
                            initialDate: selectedJobDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setDialogState(() => selectedJobDate = pickedDate);
                          }
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Time: ${selectedTime.format(dialogContext)}"),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: dialogContext,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            setDialogState(() => selectedTime = pickedTime);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (selectedClient == null || selectedJobType == null) {
                      return;
                    }

                    String formattedDate = intl.DateFormat.yMMMd(
                      'en_US',
                    ).format(selectedJobDate);
                    String formattedTime = selectedTime.format(dialogContext);

                    Job newJob = Job(
                      clientId: selectedClient!.id!,
                      date: formattedDate,
                      time: formattedTime,
                      status: "Scheduled",
                      jobName: selectedJobType!.name,
                      notes: notesController.text,
                    );

                    await DatabaseHelper.instance.addJob(newJob);

                    if (context.mounted) {
                      _loadJobs();
                      Navigator.pop(dialogContext);
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

  void _showNoClientsWarning() {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("No Clients Found"),
            content: const Text(
              "You need to add at least one client before creating a job.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  void _showNoServicesWarning() {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("No Job Types Found"),
            content: const Text(
              "You need to add at least one job type before creating a job.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          key: Key('dashboard_title'),
          'Dashboard',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            key: Key('appointment_calendar'),
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.pushNamed(context, '/calendar');
            },
          ),
          IconButton(
            key: Key('services'),
            icon: const Icon(Icons.assignment),
            onPressed: () {
              Navigator.pushNamed(context, '/services');
            },
          ),
          IconButton(
            key: Key('clients'),
            icon: const Icon(Icons.contacts),
            onPressed: () {
              Navigator.pushNamed(context, '/clients');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${intl.DateFormat.yMMMd('en_US').format(selectedDate)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    setState(() {
                      selectedDate = pickedDate ?? selectedDate;
                    });
                    _loadJobs();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
                jobs.isEmpty
                    ? const Center(
                      child: Text("No jobs scheduled for this day."),
                    )
                    : ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(
                                  "${job.jobName} - ${job.time}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "${job.clientName} | ${job.status} | ${job.notes ?? 'No notes'}",
                                ),

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.navigation,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _launchMaps(job.clientId),
                                    ),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        if (value == 'call') {
                                          _callClient(job.clientId);
                                        } else if (value == 'text') {
                                          _textClient(job.clientId);
                                        }
                                      },
                                      itemBuilder:
                                          (context) => [
                                            const PopupMenuItem(
                                              value: 'call',
                                              child: Text('Call Client'),
                                            ),
                                            const PopupMenuItem(
                                              value: 'text',
                                              child: Text('Text Client'),
                                            ),
                                          ],
                                      child: const Icon(
                                        Icons.phone,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  setState(() {
                                    job.expanded = !job.expanded;
                                  });
                                },
                              ),
                              if (job.expanded) ...[
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.orange,
                                            ),
                                            label: const Text('Edit'),
                                            onPressed: () => _editJob(job),
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            label: const Text('Cancel'),
                                            onPressed: () => _cancelJob(job.id),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.note_add,
                                              color: Colors.green,
                                            ),
                                            label: const Text('Add Notes'),
                                            onPressed: () => _addNotes(job),
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(
                                              Icons.check_circle,
                                              color: Colors.blue,
                                            ),
                                            label: const Text('Mark Completed'),
                                            onPressed: () async {
                                              if (job.id == null) {
                                                debugPrint(
                                                  "Error: Job ID is null",
                                                );
                                                return;
                                              }

                                              await DatabaseHelper.instance
                                                  .updateJobStatus(
                                                    job.id!,
                                                    'Completed',
                                                  );
                                              setState(() {
                                                job.status = 'Completed';
                                                job.expanded = false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: Key('add_job'),
        onPressed: _showAddJobDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
