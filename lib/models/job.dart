class Job {
  int? id;
  int clientId;
  String date;
  String time;
  String status;
  String jobName;
  String? notes;
  bool expanded;
  String? clientName;

  Job({
    this.id,
    required this.clientId,
    required this.date,
    required this.time,
    required this.status,
    required this.jobName,
    this.notes,
    this.expanded = false,
    this.clientName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'date': date,
      'time': time,
      'status': status,
      'job_name': jobName,
      'notes': notes,
    };
  }

  factory Job.fromMap(Map<String, dynamic> map) {
    return Job(
      id: map['id'],
      clientId: map['client_id'],
      date: map['date'],
      time: map['time'],
      status: map['status'],
      jobName: map['job_name'],
      notes: map['notes'],
    );
  }

  Job copyWith({
    int? id,
    int? clientId,
    String? date,
    String? time,
    String? status,
    String? jobName,
    String? notes,
    bool? expanded,
    String? clientName,
  }) {
    return Job(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      jobName: jobName ?? this.jobName,
      notes: notes ?? this.notes,
      expanded: expanded ?? this.expanded,
      clientName: clientName ?? this.clientName,
    );
  }
}
