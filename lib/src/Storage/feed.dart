import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import './dbinit.dart';

int milisecondsIn30Days = 30 * 24 * 60 * 60 * 1000;
// Database? db;
// Future<Database?> getDb() async {
//   try {
//     if (db != null) return db;
//     sqfliteFfiInit();
//     databaseFactory = databaseFactoryFfiWeb;
//     db ??= await openDatabase('my_db.db', version: 1,
//         onCreate: (Database db, int version) async {
//       print("Creating tabke");
//       // When creating the db, create the table
//       await db.execute(
//           'CREATE TABLE feed (post_id varchar(30) UNIQUE, score INTEGER, is_seen BOOL DEFAULT FALSE, created_at int)');
//     });
//     return db;
//   } catch (e) {
//     print(e);
//     return null;
//   }
// }

Future<void> markSeen(String postId) async {
  var thisdb = await getDb();
  try {
    print("marking seen: $postId");
    print(thisdb);
    await thisdb?.rawQuery(
        "UPDATE feed SET score = score - 100, is_seen = true WHERE post_id = $postId; ");
  } catch (e) {
    print(e);
  }
}

Future<List<String>> getPostIds(int offset, int limit) async {
  var thisdb = await getDb();
  var feed = await thisdb?.rawQuery(
      "SELECT * FROM feed ORDER BY score DESC LIMIT $limit OFFSET $offset; ");
  var length = feed?.length ?? 0;
  List<String> posts = [];
  for (int i = 0; i < length; ++i) {
    print(feed?[i]);
    var str = feed?[i]["post_id"].toString();
    if (str != null) posts.add(str);
  }

  return posts;
}

var localPosts = [];

Future<void> generateFeed(List<Map<String, dynamic>> posts) async {
  int now = DateTime.now().millisecondsSinceEpoch;
  // print(now);
  // print(posts);
  // print(db);
  if (db == null) {
    await getDb();
    print("GOT DB");
  }
  try {
    for (var row in posts) {
      await db?.rawQuery(
          "INSERT OR IGNORE INTO feed (post_id, score, is_seen, created_at) VALUES (?, ?, ?, ?)",
          [
            row['post_id'],
            row['score'],
            row['is_seen'] ? 1 : 0,
            row['created_at']
          ]);
      print(row);
    }
    var a = await getPostIds(0, 20);
    print("INSERTED DATA");
    print(a);
  } catch (e) {
    print(e);
  }
  // try {
  //   await db?.rawQuery(
  //       "DELETE FROM feed where created_at < ${now - milisecondsIn30Days};");
  //   await db?.transaction((txn) async {
  //     print(txn);
  //     Batch batch = txn.batch();

  //     // Add each insert operation to the batch
  //     print(posts);
  //     for (var row in posts) {
  //       print(row);
  //       batch.rawInsert('''
  //         INSERT OR IGNORE INTO feed (post_id, score, is_seen, created_at)
  //         VALUES (?, ?, ?, ?)
  //       ''', [
  //         row['post_id'],
  //         row['score'],
  //         row['is_seen'] ? 1 : 0,
  //         row['created_at']
  //       ]);
  //     }

  //     // Execute the batch insert
  //     await batch.commit(noResult: true);
  //     var a = await getPostIds(0, 20);
  //     print("INSERTED DATA");
  //     print(a);
  //   });
  // } catch (e) {
  //   print(e);
  // }
}
