import 'team.dart';

class Match {
  final int id;
  final DateTime utcDate;
  final String status;
  final int? matchday;
  final String stage;
  final Team homeTeam;
  final Team awayTeam;
  final int? homeScore;
  final int? awayScore;
  final String? winner; // HOME_TEAM, AWAY_TEAM, DRAW
  final String? venue;
  final String? referee;
  final Map<String, dynamic>? competition;

  Match({
    required this.id,
    required this.utcDate,
    required this.status,
    this.matchday,
    required this.stage,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    this.winner,
    this.venue,
    this.referee,
    this.competition,
  });

  // Factory constructor to create Match from JSON (Football-Data.org format)
  factory Match.fromJson(Map<String, dynamic> json) {
    final scoreData = json['score'];

    return Match(
      id: json['id'] ?? 0,
      utcDate: DateTime.parse(
        json['utcDate'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['status'] ?? 'SCHEDULED',
      matchday: json['matchday'],
      stage: json['stage'] ?? 'REGULAR_SEASON',
      homeTeam: Team.fromJson(json['homeTeam'] ?? {}),
      awayTeam: Team.fromJson(json['awayTeam'] ?? {}),
      homeScore: scoreData?['fullTime']?['home'],
      awayScore: scoreData?['fullTime']?['away'],
      winner: scoreData?['winner'],
      venue: json['venue'],
      referee: json['referees'] != null && (json['referees'] as List).isNotEmpty
          ? json['referees'][0]['name']
          : null,
      competition: json['competition'],
    );
  }

  // Convert Match to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'utcDate': utcDate.toIso8601String(),
      'status': status,
      'matchday': matchday,
      'stage': stage,
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'homeScore': homeScore,
      'awayScore': awayScore,
      'winner': winner,
      'venue': venue,
      'referee': referee,
      'competition': competition,
    };
  }

  // Convert Match to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'utc_date': utcDate.toIso8601String(),
      'status': status,
      'matchday': matchday,
      'stage': stage,
      'home_team_id': homeTeam.id,
      'away_team_id': awayTeam.id,
      'home_score': homeScore,
      'away_score': awayScore,
      'winner': winner,
      'venue': venue,
      'referee': referee,
      'competition_name': competition?['name'],
      'competition_code': competition?['code'],
    };
  }

  // Getters for convenience
  bool get isFinished => status == 'FINISHED';
  bool get isLive => status == 'IN_PLAY' || status == 'PAUSED';
  bool get isScheduled => status == 'SCHEDULED' || status == 'TIMED';
  bool get isPostponed => status == 'POSTPONED';
  bool get isCancelled => status == 'CANCELLED';

  // Alias for compatibility
  DateTime get date => utcDate;

  String get result {
    if (homeScore == null || awayScore == null) return '-';
    return '$homeScore - $awayScore';
  }

  String get winnerName {
    if (winner == null || winner == 'DRAW') return 'Draw';
    if (winner == 'HOME_TEAM') return homeTeam.name;
    if (winner == 'AWAY_TEAM') return awayTeam.name;
    return 'TBD';
  }

  String? get leagueName => competition?['name'];
  String? get leagueCode => competition?['code'];
  int? get leagueId => competition?['id'];
  int? get round => matchday;

  @override
  String toString() {
    return 'Match{${homeTeam.name} vs ${awayTeam.name}, $result, $status}';
  }
}
