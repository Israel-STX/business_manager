import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../db/firebase_helper.dart';
import '../models/job.dart';
import '../models/client.dart';
import '../models/services.dart';
import '../widgets/create_job.dart';
import '../widgets/edit_job.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Job> todayJobs = [];
  List<Job> upcomingJobs = [];
  List<Client> clients = [];
  List<Services> services = [];
  late DateTime today;
  StreamSubscription? _jobSub;
  String? _expandedJobId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    _loadClients();
    _loadServices();
    _startListeningToJobs();
  }

  // get all services from firestore
  Future<void> _loadServices() async {
    final loaded = await FirebaseHelper.getServices();
    setState(() => services = loaded);
  }

  // get all clients from firestore
  Future<void> _loadClients() async {
    final loaded = await FirebaseHelper.getClients();
    setState(() => clients = loaded);
  }

  // listen for job updates in realtime
  void _startListeningToJobs() {
    _jobSub = FirebaseHelper.listenToJobs().listen((jobs) {
      final todayKey = _formatDate(today);
      final todayList = <Job>[];
      final upcoming = <Job>[];

      for (final job in jobs) {
        if (job.date == todayKey) {
          todayList.add(job);
        } else {
          try {
            final jobDate = DateFormat.yMMMd('en_US').parse(job.date);
            if (jobDate.isAfter(today)) upcoming.add(job);
          } catch (_) {}
        }
      }

      todayList.sort((a, b) => _timeStringToMinutes(a.time).compareTo(_timeStringToMinutes(b.time)));
      upcoming.sort((a, b) {
        final cmp = a.date.compareTo(b.date);
        return cmp != 0 ? cmp : _timeStringToMinutes(a.time).compareTo(_timeStringToMinutes(b.time));
      });

      setState(() {
        todayJobs = todayList;
        upcomingJobs = upcoming;
      });
    });
  }

  @override
  void dispose() {
    _jobSub?.cancel();
    super.dispose();
  }

  // format date like Apr 12, 2025
  String _formatDate(DateTime date) => DateFormat.yMMMd('en_US').format(date);

  // format date like Friday, April 12, 2025
  String _readableHeaderDate(DateTime date) => DateFormat('EEEE, MMMM d, y').format(date);

  // convert time string to total minutes for sorting
  int _timeStringToMinutes(String time) {
    try {
      final dt = DateFormat("h:mm a").parse(time);
      return dt.hour * 60 + dt.minute;
    } catch (_) {
      return 0;
    }
  }

  // reusable section title
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  // build one job card
  Widget _buildJobCard(Job job) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            title: Text('${job.jobName} — ${job.time}', style: Theme.of(context).textTheme.titleMedium),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (job.clientName?.isNotEmpty ?? false)
                  Text('Client: ${job.clientName}', style: Theme.of(context).textTheme.bodyLarge),
                if (job.clientPhone?.isNotEmpty ?? false)
                  Text('Phone: ${job.clientPhone}', style: Theme.of(context).textTheme.bodyLarge),
                if (job.notes?.isNotEmpty ?? false)
                  Text('Notes: ${job.notes}', style: Theme.of(context).textTheme.bodyLarge),
                if (job.date != _formatDate(DateTime.now()))
                  Text('Date: ${job.date}', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // open client address in maps
                IconButton(
                  icon: const Icon(Icons.navigation, color: Colors.black),
                  tooltip: 'Directions',
                  onPressed: () {
                    final client = clients.firstWhere(
                      (c) => c.id == job.clientId,
                      orElse: () => Client(id: '', name: '', phone: '', address: '', notes: ''),
                    );
                    if (client.address?.isNotEmpty ?? false) {
                      final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(client.address!)}");
                      launchUrl(url);
                    }
                  },
                ),
                // call client phone number
                IconButton(
                  icon: const Icon(Icons.phone, color: Colors.black),
                  tooltip: 'Call',
                  onPressed: () {
                    final phone = job.clientPhone;
                    if (phone?.isNotEmpty ?? false) {
                      final url = Uri.parse("tel:$phone");
                      launchUrl(url);
                    }
                  },
                ),
                // expand editor dropdown
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.black),
                  tooltip: 'Edit Job',
                  onPressed: () {
                    setState(() => _expandedJobId = _expandedJobId == job.id ? null : job.id);
                  },
                ),
              ],
            ),
          ),
          if (_expandedJobId == job.id)
            EditJobDropdown(
              job: job,
              clients: clients.isNotEmpty ? clients : [Client(id: '', name: 'Unknown', phone: '', address: '', notes: '')],
              onCancel: () => setState(() => _expandedJobId = null),
              onSave: () async {
                await _loadClients();
                setState(() => _expandedJobId = null);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            // header
            Text(_readableHeaderDate(today), style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            // today's jobs
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
