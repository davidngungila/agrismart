import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/user_model.dart';

class DbService {
  static final DbService _instance = DbService._internal();
  factory DbService() => _instance;
  DbService._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'agrismart.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Users table for local auth
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE,
            password TEXT,
            name TEXT,
            phone TEXT,
            role TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final res = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
      limit: 1,
    );
    if (res.isEmpty) return null;
    return User.fromJson(res.first);
  }

  Future<void> insertUser(User user, {required String password}) async {
    final db = await database;
    await db.insert(
      'users',
      {
        ...user.toJson(),
        'password': password,
        'email': user.email.toLowerCase(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}



