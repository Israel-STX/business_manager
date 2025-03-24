import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/client.dart';
import '../models/job.dart';
import '../models/payment.dart';
import '../models/services.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  static const int _databaseVersion = 2;

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
        notes TEXT,
        FOREIGN KEY (client_id) REFERENCES clients(id) ON DELETE CASCADE
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
    SELECT jobs.*, clients.name AS title, clients.address, clients.phone
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

  // **JOB TYPE CRUD FUNCTIONS** ✅

  Future<int> addService(Services services) async {
    final db = await instance.database;
    return await db.insert('services', services.toMap());
  }

  Future<List<Services>> getServices() async {
    final db = await instance.database;
    final result = await db.query('services');
    return result.map((map) => Services.fromMap(map)).toList();
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
}
