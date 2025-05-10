class Client {
  final String id;
  final String name;
  final String? address;
  final String? phone;
  final String? notes;
  final String? email;

  Client({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.notes,
    this.email,
  });

  // convert client to map for firestore
  Map<String, dynamic> toMap() => {
        'name': name,
        'address': address,
        'phone': phone,
        'notes': notes,
        'email': email,
      };

  // create client from firestore map
  factory Client.fromMap(Map<String, dynamic> map, String id) => Client(
        id: id,
        name: map['name'],
        address: map['address'],
        phone: map['phone'],
        notes: map['notes'],
        email: map['email'],
      );

  // compare clients by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client && runtimeType == other.runtimeType && id == other.id;

  // required when overriding
  @override
  int get hashCode => id.hashCode;

  // copy a client and update fields if needed
  Client copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? notes,
    String? email,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      email: email ?? this.email,
    );
  }
}
