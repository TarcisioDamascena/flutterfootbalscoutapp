class Odds {
  final int matchId;
  final double homeWinOdds;
  final double drawOdds;
  final double awayWinOdds;
  final double? homeWinProbability;
  final double? drawProbability;
  final double? awayWinProbability;
  final String source; // 'api' or 'calculated'
  final DateTime lastUpdated;

  Odds({
    required this.matchId,
    required this.homeWinOdds,
    required this.drawOdds,
    required this.awayWinOdds,
    this.homeWinProbability,
    this.drawProbability,
    this.awayWinProbability,
    required this.source,
    required this.lastUpdated,
  });

  // Factory constructor to create Odds from JSON
  factory Odds.fromJson(Map<String, dynamic> json) {
    return Odds(
      matchId: json['matchId'] ?? 0,
      homeWinOdds: (json['homeWinOdds'] ?? 0.0).toDouble(),
      drawOdds: (json['drawOdds'] ?? 0.0).toDouble(),
      awayWinOdds: (json['awayWinOdds'] ?? 0.0).toDouble(),
      homeWinProbability: json['homeWinProbability']?.toDouble(),
      drawProbability: json['drawProbability']?.toDouble(),
      awayWinProbability: json['awayWinProbability']?.toDouble(),
      source: json['source'] ?? 'calculated',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : DateTime.now(),
    );
  }

  // Convert Odds to JSON
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'homeWinOdds': homeWinOdds,
      'drawOdds': drawOdds,
      'awayWinOdds': awayWinOdds,
      'homeWinProbability': homeWinProbability,
      'drawProbability': drawProbability,
      'awayWinProbability': awayWinProbability,
      'source': source,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Convert Odds to Map for database
  Map<String, dynamic> toMap() {
    return {
      'match_id': matchId,
      'home_win_odds': homeWinOdds,
      'draw_odds': drawOdds,
      'away_win_odds': awayWinOdds,
      'home_win_probability': homeWinProbability,
      'draw_probability': drawProbability,
      'away_win_probability': awayWinProbability,
      'source': source,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  // Create Odds from database Map
  factory Odds.fromMap(Map<String, dynamic> map) {
    return Odds(
      matchId: map['match_id'],
      homeWinOdds: map['home_win_odds'],
      drawOdds: map['draw_odds'],
      awayWinOdds: map['away_win_odds'],
      homeWinProbability: map['home_win_probability'],
      drawProbability: map['draw_probability'],
      awayWinProbability: map['away_win_probability'],
      source: map['source'],
      lastUpdated: DateTime.parse(map['last_updated']),
    );
  }

  // Calculate implied probabilities from odds
  static Map<String, double> calculateImpliedProbabilities({
    required double homeOdds,
    required double drawOdds,
    required double awayOdds,
  }) {
    final homeProb = 1 / homeOdds;
    final drawProb = 1 / drawOdds;
    final awayProb = 1 / awayOdds;

    final total = homeProb + drawProb + awayProb;

    return {
      'home': (homeProb / total) * 100,
      'draw': (drawProb / total) * 100,
      'away': (awayProb / total) * 100,
    };
  }

  @override
  String toString() {
    return 'Odds{Home: $homeWinOdds, Draw: $drawOdds, Away: $awayWinOdds}';
  }
}
