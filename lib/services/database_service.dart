import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/constants/app_constants.dart';
import '../models/team.dart';
import '../models/match.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Teams table (updated for Football-Data.org)
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        short_name TEXT,
        tla TEXT,
        crest TEXT,
        address TEXT,
        website TEXT,
        founded INTEGER,
        club_colors TEXT,
        venue TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Matches table (updated for Football-Data.org)
    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY,
        utc_date TEXT NOT NULL,
        status TEXT NOT NULL,
        matchday INTEGER,
        stage TEXT,
        home_team_id INTEGER NOT NULL,
        away_team_id INTEGER NOT NULL,
        home_score INTEGER,
        away_score INTEGER,
        winner TEXT,
        venue TEXT,
        referee TEXT,
        competition_name TEXT,
        competition_code TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (home_team_id) REFERENCES teams (id),
        FOREIGN KEY (away_team_id) REFERENCES teams (id)
      )
    ''');

    // Favorite teams table
    await db.execute('''
      CREATE TABLE favorite_teams (
        team_id INTEGER PRIMARY KEY,
        added_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (team_id) REFERENCES teams (id)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_matches_date ON matches(utc_date)');
    await db.execute('CREATE INDEX idx_matches_status ON matches(status)');
    await db.execute(
      'CREATE INDEX idx_matches_competition ON matches(competition_code)',
    );
  }

  // Team operations
  Future<int> insertTeam(Team team) async {
    final db = await database;
    return await db.insert(
      'teams',
      team.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Team>> getAllTeams() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('teams');
    return List.generate(maps.length, (i) => Team.fromMap(maps[i]));
  }

  Future<Team?> getTeamById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'teams',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Team.fromMap(maps.first);
    }
    return null;
  }

  // Match operations
  Future<int> insertMatch(Match match) async {
    final db = await database;
    return await db.insert(
      'matches',
      match.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getMatches({
    String? status,
    String? competitionCode,
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    List<String> conditions = [];

    if (status != null) {
      conditions.add('status = ?');
      whereArgs.add(status);
    }

    if (competitionCode != null) {
      conditions.add('competition_code = ?');
      whereArgs.add(competitionCode);
    }

    if (from != null && to != null) {
      conditions.add('utc_date BETWEEN ? AND ?');
      whereArgs.addAll([from.toIso8601String(), to.toIso8601String()]);
    }

    if (conditions.isNotEmpty) {
      whereClause = conditions.join(' AND ');
    }

    return await db.query(
      'matches',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'utc_date DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getMatchesByCompetition(
    String competitionCode,
  ) async {
    final db = await database;
    return await db.query(
      'matches',
      where: 'competition_code = ?',
      whereArgs: [competitionCode],
      orderBy: 'utc_date DESC',
    );
  }

  // Favorite teams operations
  Future<int> addFavoriteTeam(int teamId) async {
    final db = await database;
    return await db.insert('favorite_teams', {
      'team_id': teamId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> removeFavoriteTeam(int teamId) async {
    final db = await database;
    return await db.delete(
      'favorite_teams',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
  }

  Future<List<int>> getFavoriteTeamIds() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorite_teams');
    return List.generate(maps.length, (i) => maps[i]['team_id'] as int);
  }

  Future<bool> isFavoriteTeam(int teamId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'favorite_teams',
      where: 'team_id = ?',
      whereArgs: [teamId],
    );
    return maps.isNotEmpty;
  }

  // Clear all data
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('teams');
    await db.delete('matches');
    await db.delete('favorite_teams');
  }

  // Delete database (for debugging)
  Future<void> deleteDatabase() async {
    String path = join(await getDatabasesPath(), AppConstants.databaseName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
