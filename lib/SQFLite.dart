import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'meter_reading.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE MeterReading (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reading TEXT
      )
    ''');
  }

  Future<void> insertReading(String reading) async {
    final Database db = await instance.database;
    await db.insert(
      'MeterReading',
      {'reading': reading},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>> getReadings() async {
    final Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('MeterReading');
    return List.generate(maps.length, (index) => maps[index]['reading'] as String);
  }
}
