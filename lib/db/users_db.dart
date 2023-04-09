import "./db_init.dart";

class UserDbOperation {
  // Create a new user and sets tokens to [zero]
  //  Returns the [zero] if failure in creating new user
  static Future<int> createUser(String name, String id, String mob) async {
    final db = await AppDatabase.instance.database;
    var queryStatus = await db.insert("USERS", {
      "NAME": name,
      "ID": id,
      "MOB": mob,
      "TOKENS": 0,
    });
    return queryStatus;
  }

  /// Returns a Account based on id
  /// If account not present the returns null
  static Future<Map<String, Object?>?> getAccount(String id) async {
    final db = await AppDatabase.instance.database;
    var query = await db.query("USERS", where: "ID = ?", whereArgs: [id]);
    if (query.isEmpty) {
      return null;
    }
    return query.first;
  }

// Deletes the user based on the id
  static void deleteUser(String id) async {
    final db = await AppDatabase.instance.database;
    db.delete("USERS", where: "ID = ?", whereArgs: [id]);
  }

//Decements the token and return the user info
  static Future<Map<String, Object?>> decrementToken(String id) async {
    final db = await AppDatabase.instance.database;
    var record = await db.query("USERS", where: "ID = ?", whereArgs: [id]);
    var token = record.first["TOKENS"] as int;
    db.update("USERS", {"TOKENS": (token - 1)},
        where: "ID = ?", whereArgs: [id]);
    var temp = await db.query("USERS", where: "ID = ?", whereArgs: [id]);
    return temp.first;
  }

// Increments  TOKENS by tokens for the user with ID id
  static Future<Map<String, Object?>> incrementToken(
    String id,
    int tokens,
  ) async {
    final db = await AppDatabase.instance.database;
    var record = await db.query("USERS", where: "ID = ?", whereArgs: [id]);
    var token = record.first["TOKENS"] as int;
    db.update("USERS", {"TOKENS": (token + tokens)},
        where: "ID = ?", whereArgs: [id]);
    var temp = await db.query("USERS", where: "ID = ?", whereArgs: [id]);
    return temp.first;
  }

// Query user database and results list of users
  static Future<List<Map<String, Object?>>> getAccounts() async {
    final db = await AppDatabase.instance.database;
    return db.query("USERS");
  }

  // print db records

  static void printRecords() async {
    final db = await AppDatabase.instance.database;
    var records = await db.query("USERS");
    if (records.isEmpty) {
      print("No Records yet");
      return;
    }
    print("The Results are");
    for (var record in records) {
      print(
          "${record['NAME']}  ${record['ID']}  ${record['TOKENS']}  ${record['MOB']}");
    }
  }
}
