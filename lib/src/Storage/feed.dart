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
    await thisdb?.rawQuery("""
      UPDATE feed SET score = CASE 
                WHEN score - 100 >= 1000 THEN score - 100 
                ELSE 1000 
            END, is_seen = true WHERE post_id = '$postId';
            """);
  } catch (e) {
    print(e);
  }
}

Future<List<String>> getPostIds(int offset, int limit,
    {bool isSeen = false}) async {
  var thisdb = await getDb();
  var feed = await thisdb?.rawQuery(
      "SELECT * FROM feed ORDER BY is_seen DESC, score DESC, post_id DESC LIMIT $limit OFFSET $offset; ");
  var length = feed?.length ?? 0;
  List<String> posts = [];
  for (int i = 0; i < length; ++i) {
    // print(feed?[i]);
    var str = feed?[i]["post_id"].toString();
    if (str != null) posts.add(str);
  }

  return posts;
}

var localPosts = [];

Future<void> generateFeed(List<Map<String, dynamic>> posts,
    {int newPost = 0}) async {
  int now = DateTime.now().millisecondsSinceEpoch;
  // print(now);
  // print(posts);
  // print(db);
  if (db == null) {
    await getDb();
    // print("GOT DB");
  }
  try {
    print("GENERATING FEED");
    for (var row in posts) {
      await db?.rawQuery(
        "INSERT OR IGNORE INTO feed (post_id, score, is_seen, created_at) VALUES (?, ?, ?, ?)",
        [
          row['postId'],
          row['score'],
          newPost,
          row['timestamp'],
        ],
      );
      print(row);
    }
    // var a = await getPostIds(0, 20);
    // print("INSERTED DATA");
    // print(a);
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

Future<void> markSeenBatch(int tot) async {
  final topNRows = await getPostIds(0, tot);

  for (var row in topNRows) {
    await markSeen(row);
  }
}
