class Client {
  int? id;
  String name;
  String? address;
  String? phone;
  String? notes;

  Client({this.id, required this.name, this.address, this.phone, this.notes});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'notes': notes,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      address: map['address'],
      phone: map['phone'],
      notes: map['notes'],
    );
  }
}
