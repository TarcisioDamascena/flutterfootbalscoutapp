class Team {
  final int id;
  final String name;
  final String? logo;
  final String? country;
  final int? founded;
  final String? venue;
  final int? venueCapacity;

  Team({
    required this.id,
    required this.name,
    this.logo,
    this.country,
    this.founded,
    this.venue,
    this.venueCapacity,
  });

  // Factory constructor to create Team from JSON
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? json['team']?['id'] ?? 0,
      name: json['name'] ?? json['team']?['name'] ?? 'Unknown',
      logo: json['logo'] ?? json['team']?['logo'],
      country: json['country'] ?? json['team']?['country'],
      founded: json['founded'] ?? json['team']?['founded'],
      venue: json['venue']?['name'],
      venueCapacity: json['venue']?['capacity'],
    );
  }

  // Convert Team to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'country': country,
      'founded': founded,
      'venue': venue,
      'venueCapacity': venueCapacity,
    };
  }

  // Convert Team to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'country': country,
      'founded': founded,
      'venue': venue,
      'venue_capacity': venueCapacity,
    };
  }

  // Create Team from database Map
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      name: map['name'],
      logo: map['logo'],
      country: map['country'],
      founded: map['founded'],
      venue: map['venue'],
      venueCapacity: map['venue_capacity'],
    );
  }

  @override
  String toString() {
    return 'Team{id: $id, name: $name, country: $country}';
  }
}
