class Client {
  // id of the client (usually the firestore document id)
  final String id;

  // name of the client (this is required)
  final String name;

  // address of the client (optional)
  final String? address;

  // phone number of the client (optional)
  final String? phone;

  // any notes about the client (optional)
  final String? notes;

  // this makes a new client object
  Client({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    this.notes,
  });

  // turns this client into a map so we can save it to firestore
  Map<String, dynamic> toMap() => {
    'name': name,
    'address': address,
    'phone': phone,
    'notes': notes,
  };

  // makes a client from firestore data and uses the doc id as the id
  factory Client.fromMap(Map<String, dynamic> map, String id) => Client(
    id: id,
    name: map['name'],
    address: map['address'],
    phone: map['phone'],
    notes: map['notes'],
  );

  // lets flutter dropdowns and comparisons know when two clients are the same (based on id)
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Client && runtimeType == other.runtimeType && id == other.id;

  // also needed for dropdowns to work right
  @override
  int get hashCode => id.hashCode;

  // lets us copy a client and change some of its fields if we want to
  Client copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? notes,
  }) {
    return Client(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
    );
  }
}
