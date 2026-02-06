class Team {
  final int id;
  final String name;
  final String? shortName;
  final String? tla; // Three Letter Abbreviation
  final String? crest; // Team logo/crest URL
  final String? address;
  final String? website;
  final int? founded;
  final String? clubColors;
  final String? venue;

  Team({
    required this.id,
    required this.name,
    this.shortName,
    this.tla,
    this.crest,
    this.address,
    this.website,
    this.founded,
    this.clubColors,
    this.venue,
  });

  // Factory constructor to create Team from JSON (Football-Data.org format)
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      shortName: json['shortName'],
      tla: json['tla'],
      crest: json['crest'],
      address: json['address'],
      website: json['website'],
      founded: json['founded'],
      clubColors: json['clubColors'],
      venue: json['venue'],
    );
  }

  // Convert Team to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'tla': tla,
      'crest': crest,
      'address': address,
      'website': website,
      'founded': founded,
      'clubColors': clubColors,
      'venue': venue,
    };
  }

  // Convert Team to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'short_name': shortName,
      'tla': tla,
      'crest': crest,
      'address': address,
      'website': website,
      'founded': founded,
      'club_colors': clubColors,
      'venue': venue,
    };
  }

  // Create Team from database Map
  factory Team.fromMap(Map<String, dynamic> map) {
    return Team(
      id: map['id'],
      name: map['name'],
      shortName: map['short_name'],
      tla: map['tla'],
      crest: map['crest'],
      address: map['address'],
      website: map['website'],
      founded: map['founded'],
      clubColors: map['club_colors'],
      venue: map['venue'],
    );
  }

  // Helper getter for logo (alias for crest)
  String? get logo => crest;

  // Helper getter for country (can be extracted from address if needed)
  String? get country {
    if (address != null && address!.contains(',')) {
      return address!.split(',').last.trim();
    }
    return null;
  }

  @override
  String toString() {
    return 'Team{id: $id, name: $name, tla: $tla}';
  }
}
