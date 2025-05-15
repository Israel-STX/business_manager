class Services {
  final String id;

  // name of the service
  final String name;

  // duration of the service in minutes
  final int durationMinutes;

  // constructor to create a service object
  Services({required this.id, required this.name, required this.durationMinutes});

  // converts the service object into a map for firestore storage
  Map<String, dynamic> toMap() => {
    'name': name,
    'duration_minutes': durationMinutes,
  };

  // creates a service object from a firestore map
  factory Services.fromMap(Map<String, dynamic> map, String id) => Services(
    id: id,
    name: map['name'],
    durationMinutes: map['duration_minutes'],
  );

  // overrides toString to show name and duration nicely
  @override
  String toString() => '$name - $durationMinutes mins';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true; // If they are the same instance in memory, they are equal.

    return other is Services && // Check if the 'other' object is also a Services instance.
        other.id == id; // Compare them based on their 'id' field.
  }

  @override
  int get hashCode => id.hashCode;
}
