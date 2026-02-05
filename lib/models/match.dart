import 'team.dart';

class Match {
  final int id;
  final DateTime date;
  final String status;
  final Team homeTeam;
  final Team awayTeam;
  final int? homeScore;
  final int? awayScore;
  final String? venue;
  final String? referee;
  final int? leagueId;
  final String? leagueName;
  final int? round;

  Match({
    required this.id,
    required this.date,
    required this.status,
    required this.homeTeam,
    required this.awayTeam,
    this.homeScore,
    this.awayScore,
    this.venue,
    this.referee,
    this.leagueId,
    this.leagueName,
    this.round,
  });

  // Factory constructor to create Match from JSON
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['fixture']?['id'] ?? 0,
      date: DateTime.parse(
        json['fixture']?['date'] ?? DateTime.now().toIso8601String(),
      ),
      status: json['fixture']?['status']?['short'] ?? 'NS',
      homeTeam: Team.fromJson(json['teams']?['home'] ?? {}),
      awayTeam: Team.fromJson(json['teams']?['away'] ?? {}),
      homeScore: json['goals']?['home'],
      awayScore: json['goals']?['away'],
      venue: json['fixture']?['venue']?['name'],
      referee: json['fixture']?['referee'],
      leagueId: json['league']?['id'],
      leagueName: json['league']?['name'],
      round: json['league']?['round'] != null
          ? int.tryParse(
              json['league']['round'].toString().replaceAll(
                RegExp(r'[^0-9]'),
                '',
              ),
            )
          : null,
    );
  }

  // Convert Match to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status,
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'homeScore': homeScore,
      'awayScore': awayScore,
      'venue': venue,
      'referee': referee,
      'leagueId': leagueId,
      'leagueName': leagueName,
      'round': round,
    };
  }

  // Convert Match to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'status': status,
      'home_team_id': homeTeam.id,
      'away_team_id': awayTeam.id,
      'home_score': homeScore,
      'away_score': awayScore,
      'venue': venue,
      'referee': referee,
      'league_id': leagueId,
      'league_name': leagueName,
      'round': round,
    };
  }

  // Getters for convenience
  bool get isFinished => status == 'FT';
  bool get isLive => status == '1H' || status == '2H' || status == 'HT';
  bool get isScheduled => status == 'NS' || status == 'TBD';

  String get result {
    if (homeScore == null || awayScore == null) return '-';
    return '$homeScore - $awayScore';
  }

  String get winner {
    if (homeScore == null || awayScore == null) return 'TBD';
    if (homeScore! > awayScore!) return homeTeam.name;
    if (awayScore! > homeScore!) return awayTeam.name;
    return 'Draw';
  }

  @override
  String toString() {
    return 'Match{${homeTeam.name} vs ${awayTeam.name}, $result, $status}';
  }
}
