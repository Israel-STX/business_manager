class Invoice {
  // required info about the client
  final String clientName;
  final String clientAddress;
  final String clientPhone;

  // the job/service name
  final String service;

  // extra notes if any (optional)
  final String? notes;

  // how much the service costs
  final double cost;

  // when payment is due
  final String paymentDue;

  // invoice id from firebase (optional)
  final String? id;

  // make a new invoice
  Invoice({
    required this.clientName,
    required this.clientAddress,
    required this.clientPhone,
    required this.service,
    this.notes,
    required this.cost,
    required this.paymentDue,
    this.id,
  });

  // turn this invoice into a map to save in firebase
  Map<String, dynamic> toMap() => {
        'clientName': clientName,
        'clientAddress': clientAddress,
        'clientPhone': clientPhone,
        'service': service,
        'notes': notes,
        'cost': cost,
        'paymentDue': paymentDue,
      };

  // turn firebase map back into an invoice
  factory Invoice.fromMap(Map<String, dynamic> map, String id) => Invoice(
        id: id,
        clientName: map['clientName'] ?? '',
        clientAddress: map['clientAddress'] ?? '',
        clientPhone: map['clientPhone'] ?? '',
        service: map['service'] ?? '',
        notes: map['notes'],
        cost: (map['cost'] as num).toDouble(), // cast to double safely
        paymentDue: map['paymentDue'] ?? '',
      );
}
