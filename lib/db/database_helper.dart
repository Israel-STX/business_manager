import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import '../models/client.dart';
import '../models/job.dart';
import '../models/payment.dart';
import '../models/services.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  static const int _databaseVersion = 3;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'business_manager.db');
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT,
        phone TEXT,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE jobs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('Scheduled', 'Completed', 'Canceled')),
        job_name TEXT NOT NULL,
        service_id INTEGER, -- Added service_id column
        notes TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE SET NULL -- Optional: Handle deleted services
      )
    ''');

    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        client_id INTEGER,
        job_id INTEGER,
        amount REAL NOT NULL,
        status TEXT NOT NULL CHECK(status IN ('Paid', 'Pending')),
        date TEXT NOT NULL,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE,
        FOREIGN KEY (job_id) REFERENCES jobs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE services (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        "ALTER TABLE jobs ADD COLUMN job_name TEXT NOT NULL DEFAULT '';",
      );
    }
    if (oldVersion < 3) {
      await db.execute(
        "ALTER TABLE jobs ADD COLUMN service_id INTEGER REFERENCES services(id) ON DELETE SET NULL;",
      );
    }
  }

  // ---------------------- CRUD Operations ----------------------

  // **CLIENT CRUD FUNCTIONS**

  Future<int> addClient(Client client) async {
    Database db = await instance.database;
    return await db.insert('clients', client.toMap());
  }

  Future<List<Client>> getClients() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('clients');
    return result.map((map) => Client.fromMap(map)).toList();
  }

  Future<int> updateClient(Client client) async {
    Database db = await instance.database;
    return await db.update(
      'clients',
      client.toMap(),
      where: 'id = ?',
      whereArgs: [client.id],
    );
  }

  Future<int> deleteClient(int id) async {
    Database db = await instance.database;
    return await db.delete('clients', where: 'id = ?', whereArgs: [id]);
  }

  Future<Client?> getClientById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'clients',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Client.fromMap(result.first);
    }
    return null;
  }

  // **JOB CRUD FUNCTIONS**

  Future<int> addJob(Job job) async {
    Database db = await instance.database;
    return await db.insert('jobs', job.toMap());
  }

  Future<List<Job>> getJobs() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT jobs.*, clients.name AS clientName
      FROM jobs
      INNER JOIN clients ON jobs.client_id = clients.id
    ''');
    return result.map((map) => Job.fromMap(map)).toList();
  }

  Future<int> updateJob(Job job) async {
    Database db = await instance.database;
    return await db.update(
      'jobs',
      job.toMap(),
      where: 'id = ?',
      whereArgs: [job.id],
    );
  }

  Future<int> deleteJob(int id) async {
    Database db = await instance.database;
    return await db.delete('jobs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateJobStatus(int jobId, String status) async {
    final db = await database;
    await db.update(
      'jobs',
      {'status': status},
      where: 'id = ?',
      whereArgs: [jobId],
    );
  }

  Future<List<Job>> getJobsForClientAndDate(int clientId, String date) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'jobs',
      where: 'client_id = ? AND date = ?',
      whereArgs: [clientId, date],
    );
    return result.map((map) => Job.fromMap(map)).toList();
  }

  // **PAYMENT CRUD FUNCTIONS**

  Future<int> addPayment(Payment payment) async {
    Database db = await instance.database;
    return await db.insert('payments', payment.toMap());
  }

  Future<List<Payment>> getPayments() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('payments');
    return result.map((map) => Payment.fromMap(map)).toList();
  }

  Future<int> updatePayment(Payment payment) async {
    Database db = await instance.database;
    return await db.update(
      'payments',
      payment.toMap(),
      where: 'id = ?',
      whereArgs: [payment.id],
    );
  }

  Future<int> deletePayment(int id) async {
    Database db = await instance.database;
    return await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // **SERVICES CRUD FUNCTIONS** ✅

  Future<int> addService(Services services) async {
    final db = await instance.database;
    return await db.insert('services', services.toMap());
  }

  Future<List<Services>> getServices() async {
    final db = await instance.database;
    final result = await db.query('services');
    return result.map((map) => Services.fromMap(map)).toList();
  }

  Future<Services?> getServiceById(int id) async {
    final db = await instance.database;
    final List<Map<String, dynamic>> result = await db.query(
      'services',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return Services.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateServices(Services services) async {
    final db = await instance.database;
    return await db.update(
      'services',
      services.toMap(),
      where: 'id = ?',
      whereArgs: [services.id],
    );
  }

  Future<int> deleteServices(int id) async {
    final db = await instance.database;
    return await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }

  // **CONFLICT CHECKING FOR JOB ADDITION**

  Future<bool> checkJobConflict(String date, String time, int serviceId, BuildContext context) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'jobs',
      where: 'date = ?',
      whereArgs: [date],
    );
    final existingJobsOnDate = result.map((map) => Job.fromMap(map)).toList();

    final newJobStartTime = _parseTime(time);
    final service = await getServiceById(serviceId);
    if (service == null) {
      // Handle the case where the service is not found
      return false;
    }
    final newJobEndTime = newJobStartTime.add(Duration(minutes: service.durationMinutes));

    for (final existingJob in existingJobsOnDate) {
      final existingJobStartTime = _parseTime(existingJob.time);
      final existingJobService = await getServiceById(existingJob.serviceId!);
      if (existingJobService == null || existingJob.serviceId == null) continue;
      final existingJobEndTime = existingJobStartTime.add(Duration(minutes: existingJobService.durationMinutes));

      if (_isTimeOverlapping(newJobStartTime, newJobEndTime, existingJobStartTime, existingJobEndTime)) {
        _showConflictDialog(context, existingJob.time, existingJob.jobName);
        return true; // Conflict found
      }
    }
    return false; // No conflict
  }

  Future<void> addJobWithConflictCheck(Job job, int serviceId) async {
    final db = await instance.database;
    final jobMapWithServiceId = job.toMap();
    jobMapWithServiceId['service_id'] = serviceId;
    await db.insert('jobs', jobMapWithServiceId);
  }

  DateTime _parseTime(String timeString) {
    final parts = timeString.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  bool _isTimeOverlapping(DateTime start1, DateTime end1, DateTime start2, DateTime end2) {
    return start1.isBefore(end2) && end1.isAfter(start2);
  }

  void _showConflictDialog(BuildContext context, String conflictingTime, String conflictingJobName) {
    print("Attempting to show conflict dialog");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Conflict'),
          content: Text('There is a job scheduled already at "$conflictingTime" ($conflictingJobName). Please try another time.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}