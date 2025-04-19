class Services {
  // name of the service
  final String name;

  // duration of the service in minutes
  final int durationMinutes;

  // constructor to create a service object
  Services({required this.name, required this.durationMinutes});

  // converts the service object into a map for firestore storage
  Map<String, dynamic> toMap() => {
    'name': name,
    'duration_minutes': durationMinutes,
  };

  // creates a service object from a firestore map
  factory Services.fromMap(Map<String, dynamic> map) => Services(
    name: map['name'],
    durationMinutes: map['duration_minutes'],
  );

  // overrides toString to show name and duration nicely
  @override
  String toString() => '$name - $durationMinutes mins';
}
