import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart' as intl;
import '../db/database_helper.dart';
import '../models/job.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Job>> _jobsByDate = {};

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    List<Job> allJobs = await DatabaseHelper.instance.getJobs();
    Map<String, List<Job>> jobMap = {};

    for (var job in allJobs) {
      final String key = job.date;
      jobMap.putIfAbsent(key, () => []).add(job);
    }

    setState(() {
      _jobsByDate = jobMap;
    });
  }

  List<Job> _getJobsForDay(DateTime day) {
    final key = intl.DateFormat.yMMMd('en_US').format(day);
    return _jobsByDate[key] ?? [];
  }

  Widget _buildJobTile(Job job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      elevation: 2,
      child: ListTile(
        title: Text(
          "${job.jobName} - ${job.time}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Status: ${job.status}${job.notes != null ? "\nNotes: ${job.notes}" : ""}",
        ),
        trailing: Icon(
          job.status == 'Completed'
              ? Icons.check_circle
              : job.status == 'Canceled'
              ? Icons.cancel
              : Icons.schedule,
          color:
              job.status == 'Completed'
                  ? Colors.green
                  : job.status == 'Canceled'
                  ? Colors.red
                  : Colors.orange,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedJobs =
        _selectedDay != null ? _getJobsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(title: const Text("Job Calendar")),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getJobsForDay,
            startingDayOfWeek: StartingDayOfWeek.sunday,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
          ),
          const SizedBox(height: 10),
          if (selectedJobs.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: selectedJobs.length,
                itemBuilder:
                    (context, index) => _buildJobTile(selectedJobs[index]),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("No jobs for this day."),
            ),
        ],
      ),
    );
  }
}
