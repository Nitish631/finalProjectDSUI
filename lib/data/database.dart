import 'package:sqflite/sqflite.dart';

class AdminDatabase {
  static final AdminDatabase _instance = AdminDatabase._internal();

  factory AdminDatabase() {
    return _instance;
  }

  AdminDatabase._internal() {
    _database = _initDatabase();
  }

  late Future<Database> _database;

  Future<Database> get database => _database;

  Future<Database> _initDatabase() async {
    final path = "${await getDatabasesPath()}/admin.db";

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE admin_credentials (
            id INTEGER PRIMARY KEY,
            email TEXT NOT NULL,
            password TEXT NOT NULL
          )
          ''',
        );
      },
    );
  }

Future<void> saveCredentials({
  required String email,
  required String password,
}) async {
  final db = await database;

  await db.insert(
    "admin_credentials",
    {
      "id": 1,
      "email": email,
      "password": password,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

  final result = await db.query("admin_credentials");

  print("SAVED CREDENTIALS: $result");
}

  Future<Map<String, String>?> getCredentials() async {
    final db = await database;

    final result = await db.query(
      "admin_credentials",
      where: "id = ?",
      whereArgs: [1],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return {
      "email": result.first["email"] as String,
      "password": result.first["password"] as String,
    };
  }

  Future<void> clearCredentials() async {
    final db = await database;

    await db.delete(
      "admin_credentials",
      where: "id = ?",
      whereArgs: [1],
    );
  }
}