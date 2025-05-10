class Invoice {
  final String clientName; 
  final String clientAddress;
  final String clientPhone; 
  final String clientEmail; 
  final String service; 
  final String? notes; 
  final double cost; 
  final String paymentDue; 
  final String? id;

  Invoice({
    required this.clientName,
    required this.clientAddress,
    required this.clientPhone,
    required this.clientEmail,
    required this.service,
    this.notes,
    required this.cost,
    required this.paymentDue,
    this.id,
  });

  // convert invoice to map for firestore
  Map<String, dynamic> toMap() => {
        'clientName': clientName,
        'clientAddress': clientAddress,
        'clientPhone': clientPhone,
        'clientEmail': clientEmail,
        'service': service,
        'notes': notes,
        'cost': cost,
        'paymentDue': paymentDue,
      };

  // create invoice from firestore map
  factory Invoice.fromMap(Map<String, dynamic> map, String id) => Invoice(
        id: id,
        clientName: map['clientName'] ?? '',
        clientAddress: map['clientAddress'] ?? '',
        clientPhone: map['clientPhone'] ?? '',
        clientEmail: map['clientEmail'] ?? '',
        service: map['service'] ?? '',
        notes: map['notes'],
        cost: (map['cost'] as num).toDouble(),
        paymentDue: map['paymentDue'] ?? '',
      );
}
