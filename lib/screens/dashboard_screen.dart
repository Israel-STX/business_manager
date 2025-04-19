import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/firebase_helper.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../widgets/create_job.dart';
import '../widgets/edit_job.dart';
import '../models/services.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // store today’s and upcoming jobs
  List<Job> todayJobs = [];
  List<Job> upcomingJobs = [];

  // store all clients and services
  List<Client> clients = [];
  List<Services> services = [];

  // current date without time
  late DateTime today;

  // used to stop listening to jobs when screen is closed
  StreamSubscription? _jobSub;

  // which job is currently being edited
  String? _expandedJobId;

  @override
  void initState() {
    super.initState();

    // get just the date part from now
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);

    // load clients and services from firestore
    _loadClients();
    _loadServices();

    // start listening to job changes
    _startListeningToJobs();
  }

  // get all services from firestore
  Future<void> _loadServices() async {
    final loadedServices = await FirebaseHelper.getServices();
    setState(() {
      services = loadedServices;
    });
  }

  // start live job updates
  void _startListeningToJobs() {
    _jobSub = FirebaseHelper.listenToJobs().listen((allJobs) {
      final todayKey = _formatDate(today);
      final todayList = <Job>[];
      final upcoming = <Job>[];

      // sort jobs into today and upcoming
      for (final job in allJobs) {
        if (job.date == todayKey) {
          todayList.add(job);
        } else {
          try {
            final jobDate = DateFormat.yMMMd('en_US').parse(job.date);
            if (jobDate.isAfter(today)) {
              upcoming.add(job);
            }
          } catch (_) {} // ignore invalid dates
        }
      }

      // update the job lists
      setState(() {
        todayJobs = todayList;
        upcomingJobs = upcoming;
      });
    });
  }

  // get all clients from firestore
  Future<void> _loadClients() async {
    final loadedClients = await FirebaseHelper.getClients();
    setState(() {
      clients = loadedClients;
    });
  }

  // stop listening to jobs when leaving the screen
  @override
  void dispose() {
    _jobSub?.cancel();
    super.dispose();
  }

  // convert date
  String _formatDate(DateTime date) {
    return DateFormat.yMMMd('en_US').format(date);
  }

  // convert date to something like 'Friday, April 18, 2025'
  String _readableHeaderDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  // helper to make a section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  // builds a single job card
  Widget _buildJobCard(Job job) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // job details (title, client info, etc.)
          ListTile(
            title: Text(
              '${job.jobName} — ${job.time}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (job.clientName != null)
                  Text('Client: ${job.clientName}', style: Theme.of(context).textTheme.bodyLarge),
                if (job.clientPhone != null)
                  Text('Phone: ${job.clientPhone}', style: Theme.of(context).textTheme.bodyLarge),
                if (job.notes != null && job.notes!.isNotEmpty)
                  Text('Notes: ${job.notes}', style: Theme.of(context).textTheme.bodyLarge),
                if (job.date != _formatDate(DateTime.now()))
                  Text('Date: ${job.date}', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // directions button (opens maps)
                IconButton(
                  icon: const Icon(Icons.navigation, color: Colors.blue),
                  tooltip: 'Directions',
                  onPressed: () {
                    final client = clients.firstWhere(
                      (c) => c.id == job.clientId,
                      orElse: () => Client(id: '', name: '', phone: '', address: '', notes: ''),
                    );
                    if (client.address != null && client.address!.isNotEmpty) {
                      final url = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(client.address!)}",
                      );
                      launchUrl(url);
                    }
                  },
                ),
                // call button
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.green),
                  tooltip: 'Call',
                  onPressed: () {
                    final phone = job.clientPhone;
                    if (phone != null && phone.isNotEmpty) {
                      final url = Uri.parse("tel:$phone");
                      launchUrl(url);
                    }
                  },
                ),
                // edit job button
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  tooltip: 'Edit Job',
                  onPressed: () {
                    setState(() {
                      _expandedJobId = _expandedJobId == job.id ? null : job.id;
                    });
                  },
                ),
              ],
            ),
          ),

          // if editing this job, show the editor
          if (_expandedJobId == job.id)
            EditJobDropdown(
              job: job,
              clients: clients.isNotEmpty
                  ? clients
                  : [Client(id: '', name: 'Unknown', phone: '', address: '', notes: '')],
              services: services.isNotEmpty
                  ? services
                  : [Services(name: 'Service', durationMinutes: 30)],
              onCancel: () => setState(() => _expandedJobId = null),
              onSave: () async {
                // refresh clients after editing just in case
                await _loadClients();
                setState(() => _expandedJobId = null);
              },
            ),
        ],
      ),
    );
  }

  // builds the full dashboard screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // date header at the top
            Text(_readableHeaderDate(today), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),

            // today’s jobs
            _buildSectionTitle("Today’s Jobs"),
            if (todayJobs.isEmpty)
              Text("No jobs scheduled today.", style: Theme.of(context).textTheme.bodyLarge),
            ...todayJobs.map(_buildJobCard),

            // upcoming jobs
            _buildSectionTitle("Upcoming Jobs"),
            if (upcomingJobs.isEmpty)
              Text("No upcoming jobs.", style: Theme.of(context).textTheme.bodyLarge),
            ...upcomingJobs.map(_buildJobCard),
          ],
        ),
      ),

      // button to add a new job
      floatingActionButton: FloatingActionButton(
        onPressed: () => showCreateJobDialog(
          context: context,
          clients: clients,
          services: services,
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
