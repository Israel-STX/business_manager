class Job {
  // id of the client associated with this job (from firestore)
  final String clientId;

  // date of the job (looks like 'apr 9, 2025')
  final String date;

  // time of the job (looks like '10:00 am')
  final String time;

  // name of the job
  final String jobName;

  // name of the client
  final String? clientName;

  // phone number of the client
  final String? clientPhone;

  // optional notes about the job
  final String? notes;

  // the firestore document id of the job
  final String? id;

  // constructor to create a job object
  Job({
    this.id,
    required this.clientId,
    required this.date,
    required this.time,
    required this.jobName,
    required this.clientName,
    required this.clientPhone,
    this.notes,
  });


  // converts the job object into a map for firestore storage
  Map<String, dynamic> toMap() => {
    'client_id': clientId,
    'date': date,
    'time': time,
    'job_name': jobName,
    'clientName': clientName,
    'clientPhone': clientPhone,
    'notes': notes,
  };

  // creates a job object from a firestore map
  factory Job.fromMap(Map<String, dynamic> map, [String? id]) => Job(
    id: id,
    clientId: map['client_id'],
    date: map['date'],
    time: map['time'],
    jobName: map['job_name'],
    clientName: map['clientName'],
    clientPhone: map['clientPhone'],
    notes: map['notes'],
  );

  // makes a new job with updated stuff if updated
  Job copyWith({
    String? id,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? jobName,
    String? date,
    String? time,
    String? notes,
  }) {
  return Job(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    clientName: clientName ?? this.clientName,
    clientPhone: clientPhone ?? this.clientPhone,
    jobName: jobName ?? this.jobName,
    date: date ?? this.date,
    time: time ?? this.time,
    notes: notes ?? this.notes,
    );
  }

}
