import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';
import '../models/job.dart';
import '../models/services.dart';

/*
  this is how data is stored in firebase:

  clients/               <-- collection
    └── <docId>          <-- document
         ├── name: "..."
         ├── phone: "..."
         └── address: "..."

  jobs/
    └── <docId>
         ├── clientId: "..."
         ├── jobName: "..."

  services/
    └── <docId>
         ├── name: "..."
         └── durationMinutes:
*/

class FirebaseHelper {
  // references to firebase collections
  static final _firestore = FirebaseFirestore.instance;
  static final _clientsRef = _firestore.collection('clients');
  static final _jobsRef = _firestore.collection('jobs');
  static final _servicesRef = _firestore.collection('services');

  // ---------- CLIENTS ----------

  // add a new client to firebase
  static Future<void> addClient(Client client) async {
    await _clientsRef.add(client.toMap());
  }

  // get all clients (without doc id)
  static Future<List<Client>> getClients() async {
    final snapshot = await _clientsRef.get();
    return snapshot.docs.map((doc) => Client.fromMap(doc.data(), doc.id)).toList();
  }

  // update a client by its firebase doc id
  static Future<void> updateClient(String docId, Client client) async {
    await _clientsRef.doc(docId).update(client.toMap());
  }

  // delete a client by doc id
  static Future<void> deleteClient(String docId) async {
    await _clientsRef.doc(docId).delete();
  }

  // get a single client by its id
  static Future<Client?> getClientById(String docId) async {
    final doc = await _clientsRef.doc(docId).get();
    return doc.exists ? Client.fromMap(doc.data()!, doc.id) : null;
  }

  // live updates to clients list
  static Stream<List<MapEntry<String, Client>>> listenToClients() {
    return _clientsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MapEntry(doc.id, Client.fromMap(doc.data(), doc.id))).toList();
    });
  }

  // ---------- JOBS ----------

  // add a new job
  static Future<void> addJob(Job job) async {
    await _jobsRef.add(job.toMap());
  }

  // get all jobs
  static Future<List<Job>> getJobs() async {
    final snapshot = await _jobsRef.get();
    return snapshot.docs.map((doc) => Job.fromMap(doc.data(), doc.id)).toList();
  }

  // update a job by doc id
  static Future<void> updateJob(String docId, Job job) async {
    await _jobsRef.doc(docId).update(job.toMap());
  }

  // delete a job by doc id
  static Future<void> deleteJob(String docId) async {
    await _jobsRef.doc(docId).delete();
  }

  // get live job updates
  static Stream<List<Job>> listenToJobs() {
    return _jobsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Job.fromMap(doc.data(), doc.id)).toList();
    });
  }

  // get jobs for a specific date
  static Future<List<Job>> getJobsByDate(String date) async {
    final snapshot = await _jobsRef.where('date', isEqualTo: date).get();
    return snapshot.docs.map((doc) => Job.fromMap(doc.data(), doc.id)).toList();
  }

  // ---------- SERVICES ----------

  // add a new service
  static Future<void> addService(Services service) async {
    await _servicesRef.add(service.toMap());
  }

  // get all services
  static Future<List<Services>> getServices() async {
    final snapshot = await _servicesRef.get();
    return snapshot.docs.map((doc) => Services.fromMap(doc.data())).toList();
  }

  // update service by doc id
  static Future<void> updateService(String docId, Services service) async {
    await _servicesRef.doc(docId).update(service.toMap());
  }

  // delete service by doc id
  static Future<void> deleteService(String docId) async {
    await _servicesRef.doc(docId).delete();
  }

  // listen to service updates with ids
  static Stream<List<MapEntry<String, Services>>> listenToServices() {
    return _servicesRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => MapEntry(doc.id, Services.fromMap(doc.data()))).toList();
    });
  }

  // get all services with their doc ids
  static Future<List<MapEntry<String, Services>>> getServicesWithIds() async {
    final snapshot = await _servicesRef.get();
    return snapshot.docs.map((doc) => MapEntry(doc.id, Services.fromMap(doc.data()))).toList();
  }
}
