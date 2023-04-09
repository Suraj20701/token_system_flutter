import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;
  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('m_token_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path = await _getSystemPath(filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    db.transaction(
      (txn) async {
        await txn.execute(
          '''
          CREATE TABLE USERS(
          NAME VARCHAR(20) NOT NULL,
          ID VARCHAR(15) NOT NULL,
          MOB VARCHAR(10),
          TOKENS INT,
          PRIMARY KEY(ID)
             );
        ''',
        );
      },
    );
  }

  static void deleteAppDb() async {
    final path = await _getSystemPath('app.db');
    deleteDatabase(path);
  }
}

Future<String> _getSystemPath(String filePath) async {
  final dbPath = await getDatabasesPath();
  final path = join(dbPath, filePath);
  return path;
}
