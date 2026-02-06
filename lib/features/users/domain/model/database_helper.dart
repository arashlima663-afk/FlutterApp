import 'package:flutter_application_1/features/users/domain/model/user_model.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  final Database db;

  DatabaseHelper({required this.db});
  void onCreate() async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS info (id INTEGER PRIMARY KEY AUTOINCREMENT, ownerId TEXT UNIQUE, clientPublicKeybytes BLOB, hkdfNonce BLOB, aesNonce BLOB, pubKey TEXT, jwt TEXT )',
    );
  }

  void insert(Info info) async {
    await db.insert(
      'info',
      info.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  void onCreate() async {
    await db.execute(
      'CREATE TABLE IF NOT EXISTS info (id INTEGER PRIMARY KEY AUTOINCREMENT, ownerId TEXT UNIQUE, clientPublicKeybytes BLOB, hkdfNonce BLOB, aesNonce BLOB, pubKey TEXT, jwt TEXT )',
    );
  }
}
