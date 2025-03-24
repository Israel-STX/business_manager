class Payment {
  int? id;
  int clientId;
  int jobId;
  double amount;
  String status;
  String date;

  Payment({
    this.id,
    required this.clientId,
    required this.jobId,
    required this.amount,
    required this.status,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'client_id': clientId,
      'job_id': jobId,
      'amount': amount,
      'status': status,
      'date': date,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      clientId: map['client_id'],
      jobId: map['job_id'],
      amount: map['amount'],
      status: map['status'],
      date: map['date'],
    );
  }
}
