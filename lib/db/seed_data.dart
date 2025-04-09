import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import '../models/services.dart';
import '../models/client.dart';
import '../models/job.dart';

// create test db

class SeedData {
  static Future<void> run({bool wipeExisting = false}) async {

    // dev mode setting to wipe old test data and replace with new test data
    if (wipeExisting) {
      await _deleteDatabase();
    }

    final db = DatabaseHelper.instance;

    // services test data
    final existingServices = await db.getServices();
    if (existingServices.isEmpty) {
      await db.addService(Services(name: 'Lawn Mowing', durationMinutes: 30));
      await db.addService(Services(name: 'Weeding', durationMinutes: 20));
      print('✅ Seeded services');
    }

  // client test data
    final existingClients = await db.getClients();
    int? johnId;
    int? janeId;
    if (existingClients.isEmpty) {
      johnId = await db.addClient(Client(
        name: 'John Doe',
        address: '123 Main St',
        phone: '555-1234',
        notes: '',
      ));
      janeId = await db.addClient(Client(
        name: 'Jane Smith',
        address: '456 Oak Ave',
        phone: '555-5678',
        notes: '',
      ));
      print('✅ Seeded clients');
    } else {
      johnId = existingClients.first.id;
      janeId = existingClients.length > 1 ? existingClients[1].id : johnId;
    }

    // jobs test data
    final existingJobs = await db.getJobs();
    if (existingJobs.isEmpty) {
      await db.addJob(Job(
        clientId: johnId!,
        date: 'Apr 9, 2025',
        time: '10:00 AM',
        status: 'Scheduled',
        jobName: 'Lawn Mowing',
        notes: 'Backyard focus',
      ));
      await db.addJob(Job(
        clientId: janeId!,
        date: 'Apr 15, 2025',
        time: '2:00 PM',
        status: 'Scheduled',
        jobName: 'Weeding',
        notes: '',
      ));
      print('✅ Seeded calendar jobs');
    }

    print('✅ All seed data applied');
  }

// for deleting db
  static Future<void> _deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'business_manager.db');

    if (await File(path).exists()) {
      await deleteDatabase(path);
      print('Deleted existing database for fresh database');
    } else {
      print('No existing database found to delete');
    }
  }
}
