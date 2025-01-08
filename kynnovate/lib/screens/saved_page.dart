// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:kynnovate/globals.dart';
// import 'package:url_launcher/url_launcher.dart'; // For date formatting
//
// class SavedPage extends StatelessWidget {
//   // Fetch saved news from Firestore
//   Future<List<Map<String, dynamic>>> fetchSavedNews() async {
//     try {
//       final snapshot = await FirebaseFirestore.instance
//           .collection('User')
//           .where('name', isEqualTo: globalUsername ?? 'Kaviyarasu S')
//           .get();
//
//       if (snapshot.docs.isEmpty) {
//         throw Exception('No document found with the specified field');
//       }
//
//       final docId = snapshot.docs.first.id;
//       final savedSnapshot = await FirebaseFirestore.instance
//           .collection('User')
//           .doc(docId)
//           .collection('saved')
//           .get();
//
//       return savedSnapshot.docs.map((doc) {
//         return doc.data() as Map<String, dynamic>;
//       }).toList();
//     } catch (e) {
//       print('Error fetching saved news: $e');
//       return [];
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Future<void> openLink(String url) async {
//       try {
//         await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//       } catch (e) {
//         print(e);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Could not launch $url')),
//         );
//         throw 'Could not launch $url';
//       }
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Saved News')),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: fetchSavedNews(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }
//
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No saved news'));
//           }
//
//           List<Map<String, dynamic>> newsItems = snapshot.data!;
//
//           return ListView.builder(
//             itemCount: newsItems.length,
//             itemBuilder: (context, index) {
//               var item = newsItems[index];
//               return Card(
//                 margin: EdgeInsets.all(8),
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Image
//                       item['img'] != null && item['img'].isNotEmpty
//                           ? Image.network(
//                               item['img'],
//                               width:
//                                   double.infinity, // Stretch the image across
//                               height: 200, // Image height
//                               fit: BoxFit.cover, // Cover the area
//                             )
//                           : Container(
//                               width: double.infinity,
//                               height: 200,
//                               color: Colors.grey,
//                               child: Icon(Icons.image, color: Colors.white),
//                             ),
//                       SizedBox(height: 10), // Space between image and text
//
//                       // Title
//                       Text(
//                         item['title'] ?? '',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(height: 5),
//
//                       // Description (display entire text without wrapping)
//                       Text(
//                         item['desc'] ?? '',
//                         style: TextStyle(fontSize: 14),
//                       ),
//                       SizedBox(height: 10),
//
//                       // Date (Format the date correctly)
//                       Text(
//                         item['date'] != null ? item['date'] : 'Unknown Date',
//                         style: TextStyle(fontSize: 12, color: Colors.grey),
//                       ),
//                       SizedBox(height: 10),
//
//                       // See More Button
//                       ElevatedButton(
//                         onPressed: () {
//                           openLink(item['link'] ?? "");
//                         },
//                         style: ElevatedButton.styleFrom(
//                           padding: EdgeInsets.symmetric(
//                               horizontal: 16, vertical: 10),
//                           backgroundColor: Colors.blue,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           'Read More',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:kynnovate/globals.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SavedPage extends StatefulWidget {
  @override
  _SavedPageState createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  Database? _database;

  @override
  void initState() {
    super.initState();
    // print("Global ----------------${globalUserId ?? "nothing saar"}----------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
    _initDatabase();
  }

  // Initialize SQLite database
  Future<void> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    _database = await openDatabase(
      join(dbPath, 'saved_news.db'),
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE saved_news(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            desc TEXT,
            img TEXT,
            link TEXT,
            date TEXT
          )
        ''');
      },
    );
  }

  // Fetch saved news from Firestore
  Future<List<Map<String, dynamic>>> _fetchFromFirestore() async {
    print("Global "+globalUsername!);
    try {
      // final snapshot = await FirebaseFirestore.instance
      //     .collection('User')
      //     .where('name', isEqualTo: globalUsername ?? "Kaviyarasu S")
      //     .get();
      //
      // if (snapshot.docs.isEmpty) {
      //   throw Exception('No data found for this user.');
      // }
      //
      // final docId = snapshot.docs.first.id;
      final savedSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(globalUserId)
          .collection('saved')
          .get();

      final newsList = savedSnapshot.docs.map((doc) => doc.data()).toList();

      // Cache data in SQLite
      for (var news in newsList) {
        await _insertNews(news);
      }

      return newsList;

    } catch (e) {
      print('Error fetching from Firestore: $e');
      throw Exception('Unable to fetch data from Firestore.');
    }
  }

  // Fetch saved news from SQLite
  Future<List<Map<String, dynamic>>> _fetchFromSQLite() async {
    if (_database == null) return [];
    return await _database!.query('saved_news');
  }

  // Save news to SQLite
  Future<void> _insertNews(Map<String, dynamic> news) async {
    if (_database != null) {
      await _database!.insert(
        'saved_news',
        {
          'title': news['title'] ?? '',
          'desc': news['desc'] ?? '',
          'img': news['img'] ?? '',
          'link': news['link'] ?? '',
          'date': news['date'] ?? '',
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // Fetch saved news with fallback
  Future<List<Map<String, dynamic>>> fetchSavedNews() async {
    try {
      return await _fetchFromFirestore();
    } catch (_) {
      print('Falling back to SQLite...');
      return await _fetchFromSQLite();
    }
  }

  // Launch URL
  Future<void> openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Could not launch URL: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Saved News')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSavedNews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No saved news available'),
            );
          }

          final newsItems = snapshot.data!;
          return ListView.builder(
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final item = newsItems[index];
              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        item['title'] ?? 'Untitled',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 5),

                      // Description
                      Text(
                        item['desc'] ?? 'No description available',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 10),

                      // Date
                      Text(
                        item['date'] ?? 'Unknown Date',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      SizedBox(height: 10),

                      // "Read More" Button
                      ElevatedButton(
                        onPressed: () =>
                            openLink(item['link'] ?? 'https://google.com'),
                        child: Text('Read More'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
