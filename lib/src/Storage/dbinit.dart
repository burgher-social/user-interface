import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Database? db;
Future<Database?> getDb() async {
  try {
    if (db != null) return db;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfiWeb;
    db ??= await openDatabase('my_db.db', version: 1,
        onCreate: (Database db, int version) async {
      print("Creating tabke");
      // When creating the db, create the table
      await db.execute(
        'CREATE TABLE feed (post_id varchar(30) UNIQUE, score INTEGER, is_seen BOOL DEFAULT FALSE, created_at int)',
      );
      await db.execute(
        'CREATE TABLE users (id varchar(20), username varchar(30), name varchar(20), tag varchar(4), email_id varchar(30), is_verified BOOL DEFAULT FALSE, token varchar);',
      );
    });
    return db;
  } catch (e) {
    print(e);
    return null;
  }
}
