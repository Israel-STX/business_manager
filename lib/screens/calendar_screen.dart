import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart' as intl;
import '../db/firebase_helper.dart';
import '../models/job.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // keeps track of what month we're looking at
  DateTime _focusedDay = DateTime.now();

  // keeps track of the day user tapped on
  DateTime? _selectedDay;

  // stores all jobs grouped by date
  Map<String, List<Job>> _jobsByDate = {};

  // watches the jobs collection for updates
  StreamSubscription? _jobSubscription;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _startListeningToJobs();
  }

  // listens for job changes and updates the map
  void _startListeningToJobs() {
    _jobSubscription = FirebaseHelper.listenToJobs().listen((jobs) {
      final map = <String, List<Job>>{};
      for (final job in jobs) {
        map.putIfAbsent(job.date, () => []).add(job);
      }
      setState(() {
        _jobsByDate = map;
      });
    });
  }

  // stop listening when screen is destroyed
  @override
  void dispose() {
    _jobSubscription?.cancel();
    super.dispose();
  }

  // get all jobs for a certain day
  List<Job> _getJobsForDay(DateTime day) {
    final key = intl.DateFormat.yMMMd('en_US').format(day);
    return _jobsByDate[key] ?? [];
  }

  // builds a white job card with info
  Widget _buildJobCard(Job job) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(
          '${job.jobName} — ${job.time}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.clientName != null)
              Text('Client: ${job.clientName}', style: Theme.of(context).textTheme.bodyMedium),
            if (job.clientPhone != null)
              Text('Phone: ${job.clientPhone}', style: Theme.of(context).textTheme.bodyMedium),
            if (job.notes != null && job.notes!.isNotEmpty)
              Text('Notes: ${job.notes}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // get all jobs for selected day
    final selectedJobs = _selectedDay != null ? _getJobsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Job Calendar"),
      ),
      body: Column(
        children: [
          // calendar widget to pick days
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            eventLoader: _getJobsForDay,

            // shows a black dot if there are jobs
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final isSelected = isSameDay(date, _selectedDay);
                final isToday = isSameDay(date, DateTime.now());
                if (events.isEmpty || isSelected || isToday) return const SizedBox.shrink();

                return Positioned(
                  bottom: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),

            // top header for month and arrows
            headerStyle: const HeaderStyle(
              titleCentered: true,
              formatButtonVisible: false,
              titleTextStyle: TextStyle(color: Colors.black),
              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
            ),

            // day of week labels
            daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Colors.black),
              weekendStyle: TextStyle(color: Colors.black),
            ),

            // calendar day styles
            calendarStyle: const CalendarStyle(
              defaultTextStyle: TextStyle(color: Colors.black),
              weekendTextStyle: TextStyle(color: Colors.black),
              selectedDecoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.transparent,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // bottom list of jobs for the day
          Expanded(
            child: selectedJobs.isEmpty
                ? Center(
                    child: Text(
                      "No jobs for this day.",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView(
                    children: selectedJobs.cast<Job>().map<Widget>(_buildJobCard).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
