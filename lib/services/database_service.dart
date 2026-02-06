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
    // Teams table
    await db.execute('''
      CREATE TABLE teams (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        logo TEXT,
        country TEXT,
        founded INTEGER,
        venue TEXT,
        venue_capacity INTEGER,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Matches table
    await db.execute('''
      CREATE TABLE matches (
        id INTEGER PRIMARY KEY,
        date TEXT NOT NULL,
        status TEXT NOT NULL,
        home_team_id INTEGER NOT NULL,
        away_team_id INTEGER NOT NULL,
        home_score INTEGER,
        away_score INTEGER,
        venue TEXT,
        referee TEXT,
        league_id INTEGER,
        league_name TEXT,
        round INTEGER,
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
    await db.execute('CREATE INDEX idx_matches_date ON matches(date)');
    await db.execute('CREATE INDEX idx_matches_status ON matches(status)');
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
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (status != null) {
      whereClause = 'status = ?';
      whereArgs.add(status);
    }

    if (from != null && to != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date BETWEEN ? AND ?';
      whereArgs.addAll([from.toIso8601String(), to.toIso8601String()]);
    }

    return await db.query(
      'matches',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'date DESC',
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
}
