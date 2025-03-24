class Services {
  final int? id;
  final String name;
  final int durationMinutes;

  Services({this.id, required this.name, required this.durationMinutes});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'duration_minutes': durationMinutes};
  }

  factory Services.fromMap(Map<String, dynamic> map) {
    return Services(
      id: map['id'],
      name: map['name'],
      durationMinutes: map['duration_minutes'],
    );
  }

  Services copyWith({int? id, String? name, int? durationMinutes}) {
    return Services(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMinutes: durationMinutes ?? this.durationMinutes,
    );
  }

  @override
  String toString() => '$name - $durationMinutes mins';
}
