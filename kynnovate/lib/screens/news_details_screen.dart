// import 'package:flutter/material.dart';
// // import 'package:url_launcher/url_launcher.dart';

// class NewsDetailScreen extends StatefulWidget {
//   final NewsItem newsItem;

//   NewsDetailScreen({required this.newsItem});

//   @override
//   _NewsDetailScreenState createState() => _NewsDetailScreenState();
// }

// class _NewsDetailScreenState extends State<NewsDetailScreen> {
//   bool isLiked = false; // Default state is "not liked"

//   // Function to toggle the like state
//   void toggleLike() {
//     setState(() {
//       isLiked = !isLiked;
//     });

//     // Placeholder function to update the like status in Firebase
//     updateLikeInFirebase(widget.newsItem);
//   }

//   // Empty function to update like status in Firebase
//   Future<void> updateLikeInFirebase(NewsItem newsItem) async {
//     // Placeholder for Firebase update logic
//     print("Updating like status in Firebase for ${newsItem.title}");
//   }

//   Future<void> openLink(String url) async {
//     try {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     } catch (e) {
//       print(e);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Could not launch $url')),
//       );
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context), // Back button
//         ),
//         title: Text(widget.newsItem.title),
//       ),
//       body: Stack(
//         fit: StackFit.expand, // This ensures the Stack fills the entire screen
//         children: [
//           // Background image
//           Positioned.fill(
//             child: Image.network(
//               widget.newsItem.imageUrl,
//               fit: BoxFit.cover,
//               alignment: Alignment.center,
//             ),
//           ),
//           // Gradient overlay
//           Positioned.fill(
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   colors: [
//                     Colors.black.withOpacity(0.8), // Black at the top
//                     Colors.grey.withOpacity(0.8), // Grey at the bottom
//                   ],
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                 ),
//               ),
//             ),
//           ),
//           // Foreground content
//           SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Content container
//                 Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title
//                       Text(
//                         widget.newsItem.title,
//                         style: TextStyle(
//                           fontSize: 21,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 16), // Space after title

//                       // Top image section
//                       Container(
//                         width: MediaQuery.of(context)
//                             .size
//                             .width, // Ensures image doesn't exceed screen width
//                         child: Image.network(
//                           widget.newsItem.imageUrl,
//                           height: 200,
//                           fit: BoxFit.contain,
//                           alignment: Alignment.center,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               height: 200,
//                               color: Colors.grey,
//                               child: Center(
//                                 child: Icon(Icons.broken_image,
//                                     size: 50, color: Colors.white),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                       SizedBox(height: 16), // Space after image

//                       // Author and Date section
//                       Text(
//                         "Author: ${widget.newsItem.author}",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[300], // Author color
//                         ),
//                       ),
//                       SizedBox(height: 8), // Space between Author and Date
//                       Text(
//                         "${widget.newsItem.date}",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[300],
//                         ),
//                       ),
//                       SizedBox(height: 16), // Space after Date

//                       // Description section
//                       Text(
//                         widget.newsItem.description,
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.white,
//                         ),
//                       ),
//                       SizedBox(height: 16), // Space after description

//                       // Source section
//                       Text(
//                         "Source: ${widget.newsItem.sourceName}",
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[400], // Source color
//                         ),
//                       ),
//                       SizedBox(height: 16), // Space before buttons

//                       // Row with Like and Read More buttons
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Like Button
//                           ElevatedButton.icon(
//                             onPressed: toggleLike,
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 10),
//                               backgroundColor: Colors.red,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             icon: Icon(
//                               isLiked ? Icons.favorite : Icons.favorite_border,
//                               color: Colors.white,
//                             ),
//                             label: Text(
//                               isLiked ? 'Liked' : 'Like',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                           // Read More Button
//                           ElevatedButton(
//                             onPressed: () {
//                               openLink(widget.newsItem.link ?? "");
//                             },
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(
//                                   horizontal: 16, vertical: 10),
//                               backgroundColor: Colors.blue,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             child: Text(
//                               'Read More',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/globals.dart';
import 'package:translator/translator.dart';
import 'package:url_launcher/url_launcher.dart';

class TFIDF {
  static Map<String, double> _calculateTermFrequency(List<String> document) {
    Map<String, int> termFrequency = {};
    for (var word in document) {
      termFrequency[word] = (termFrequency[word] ?? 0) + 1;
    }
    Map<String, double> tf = {};
    int totalWords = document.length;
    termFrequency.forEach((word, count) {
      tf[word] = count / totalWords;
    });
    return tf;
  }

  static Map<String, double> _calculateInverseDocumentFrequency(
      List<List<String>> documents) {
    Map<String, int> documentFrequency = {};
    for (var document in documents) {
      Set<String> uniqueWords = Set.from(document);
      uniqueWords.forEach((word) {
        documentFrequency[word] = (documentFrequency[word] ?? 0) + 1;
      });
    }
    Map<String, double> idf = {};
    int totalDocuments = documents.length;
    documentFrequency.forEach((word, count) {
      idf[word] = log(totalDocuments / (count + 1)) + 1;
    });
    return idf;
  }

  static Map<String, double> calculateTFIDF(List<List<String>> documents) {
    List<Map<String, double>> tfList = [];
    documents.forEach((document) {
      tfList.add(_calculateTermFrequency(document));
    });

    Map<String, double> idf = _calculateInverseDocumentFrequency(documents);
    Map<String, double> tfidf = {};

    for (int i = 0; i < documents.length; i++) {
      tfList[i].forEach((word, tf) {
        tfidf[word] = tf * idf[word]!;
      });
    }
    return tfidf;
  }
}

class NewsDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  NewsDetailScreen({required this.newsItem});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  final translator = GoogleTranslator();

  bool isLiked = false;
  List<String> userStrings = [];

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  Future<void> checkIfLiked() async {
    try {
      // String userName = globalUsername ?? "Kaviyarasu S";
      //
      // QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      //     .collection('User')
      //     .where('name', isEqualTo: userName)
      //     .limit(1)
      //     .get();
      //
      // if (querySnapshot.docs.isNotEmpty) {
      //   DocumentSnapshot userDocSnapshot = querySnapshot.docs.first;

      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('User').doc(globalUserId).get();

        CollectionReference savedCollection =
            userDocSnapshot.reference.collection('saved');

        QuerySnapshot savedQuerySnapshot = await savedCollection
            .where('title', isEqualTo: widget.newsItem.title)
            .limit(1)
            .get();

        setState(() {
          isLiked = savedQuerySnapshot.docs.isNotEmpty;
        });
      // }

      // else {
      //   print("No document found for user $userName in 'tempUser' collection.");
      // }
    } catch (e) {
      print("Error checking like status in Firebase: $e");
    }
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    updateLikeInFirebase(widget.newsItem);
    if (isLiked) {
      calculateAndUpdateImportantWords();
    }
  }

  Future<void> openLink(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
      throw 'Could not launch $url';
    }
  }

  // Future<void> updateLikeInFirebase(NewsItem newsItem) async {
  //   try {
  //     String userName =
  //         globalUsername ?? "Kaviyarasu S"; // Get the user's name dynamically
  //
  //     QuerySnapshot querySnapshot = await FirebaseFirestore.instance
  //         .collection('User')
  //         .where('name', isEqualTo: userName)
  //         .limit(1)
  //         .get();
  //
  //     if (querySnapshot.docs.isNotEmpty) {
  //       DocumentSnapshot userDocSnapshot = querySnapshot.docs.first;
  //
  //       CollectionReference savedCollection =
  //           userDocSnapshot.reference.collection('saved');
  //
  //       QuerySnapshot savedQuerySnapshot = await savedCollection
  //           .where('title', isEqualTo: newsItem.title)
  //           .limit(1)
  //           .get();
  //
  //       QuerySnapshot totalSavedQuerySnapshot = await savedCollection.get();
  //       int totalSavedCount = totalSavedQuerySnapshot.docs.length;
  //
  //       if (savedQuerySnapshot.docs.isNotEmpty) {
  //         // If the news item is already saved, remove it
  //         String docIdToDelete = savedQuerySnapshot.docs.first.id;
  //         await savedCollection.doc(docIdToDelete).delete();
  //         print("NewsItem removed from 'saved' collection for $userName.");
  //       } else {
  //         // If the news item is not saved, check if the total count is 10
  //         // if (totalSavedCount >= 10) {
  //         //   // Remove the first document if there are already 10 saved items
  //         //   String docIdToDelete = totalSavedQuerySnapshot.docs.first.id;
  //         //   await savedCollection.doc(docIdToDelete).delete();
  //         //   print("Removed the first document as there were 10 saved items.");
  //         // }
  //
  //         // Add the new news item to the 'saved' collection
  //         await savedCollection.add({
  //           'title': newsItem.title,
  //           'desc': newsItem.description,
  //           'link': newsItem.link,
  //           'img': newsItem.imageUrl,
  //           'date': newsItem.date
  //         });
  //         print("NewsItem saved to 'saved' collection for $userName.");
  //       }
  //     } else {
  //       print("No document found for user $userName in 'tempUser' collection.");
  //     }
  //   } catch (e) {
  //     print("Error updating like status in Firebase: $e");
  //   }
  // }

  Future<void> updateLikeInFirebase(NewsItem newsItem) async {
    try {
      // Fetch the user document directly using globalUserId
      DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(globalUserId)
          .get();

      if (userDocSnapshot.exists) {
        CollectionReference savedCollection =
        userDocSnapshot.reference.collection('saved');

        QuerySnapshot savedQuerySnapshot = await savedCollection
            .where('title', isEqualTo: newsItem.title)
            .limit(1)
            .get();

        QuerySnapshot totalSavedQuerySnapshot = await savedCollection.get();
        int totalSavedCount = totalSavedQuerySnapshot.docs.length;

        if (savedQuerySnapshot.docs.isNotEmpty) {
          // If the news item is already saved, remove it
          String docIdToDelete = savedQuerySnapshot.docs.first.id;
          await savedCollection.doc(docIdToDelete).delete();
          print("NewsItem removed from 'saved' collection.");
        } else {
          // If the news item is not saved, check if the total count is 10
          // if (totalSavedCount >= 10) {
          //   // Remove the first document if there are already 10 saved items
          //   String docIdToDelete = totalSavedQuerySnapshot.docs.first.id;
          //   await savedCollection.doc(docIdToDelete).delete();
          //   print("Removed the first document as there were 10 saved items.");
          // }

          // Add the new news item to the 'saved' collection
          await savedCollection.add({
            'title': newsItem.title,
            'desc': newsItem.description,
            'link': newsItem.link,
            'img': newsItem.imageUrl,
            'date': newsItem.date
          });
          print("NewsItem saved to 'saved' collection.");
        }
      } else {
        print("No document found for user with ID $globalUserId in 'User' collection.");
      }
    } catch (e) {
      print("Error updating like status in Firebase: $e");
    }
  }


  // Function to fetch all saved news items and perform TF-IDF calculation
  Future<void> calculateAndUpdateImportantWords() async {
    try {
      // String userName =
      //     globalUsername ?? "Kaviyarasu S"; // Get the user's name dynamically
      //
      // // Step 1: Fetch saved news items for the user
      // QuerySnapshot savedQuerySnapshot = await FirebaseFirestore.instance
      //     .collection('User')
      //     .where('name', isEqualTo: userName)
      //     .limit(1)
      //     .get();
      //
      // if (savedQuerySnapshot.docs.isNotEmpty) {
      //   DocumentSnapshot userDocSnapshot = savedQuerySnapshot.docs.first;
        DocumentSnapshot userDocSnapshot = await FirebaseFirestore.instance.collection('User').doc(globalUserId).get();


        CollectionReference savedCollection =
            userDocSnapshot.reference.collection('saved');

        QuerySnapshot savedNewsQuerySnapshot = await savedCollection.get();

        List<Map<String, dynamic>> savedItems = [];
        for (var doc in savedNewsQuerySnapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          savedItems.add({
            'title': data['title'],
            'desc': data['desc'],
          });
        }

        // Step 2: Preprocess and prepare text for TF-IDF calculation
        List<List<String>> documents = [];
        for (var item in savedItems) {
          String text = (item['title'] ?? '') + ' ' + (item['desc'] ?? '');
          List<String> words = text
              .toLowerCase()
              .split(RegExp(r'\s+'))
              .where((word) => word.isNotEmpty)
              .toList();
          documents.add(words);
        }

        // Step 3: Calculate TF-IDF
        Map<String, double> tfidfScores = TFIDF.calculateTFIDF(documents);

        // Step 4: Get the most important words (sorted by TF-IDF score)
        List<MapEntry<String, double>> sortedWords = tfidfScores.entries
            .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        List<String> importantWords =
            sortedWords.take(15).map((entry) => entry.key).toList();

        // Step 5: Update the main document with the important words
        await userDocSnapshot.reference.update({
          'words':
              importantWords, // Update 'words' field with the top 10 important words
        });

        print("Updated important words in user's document.");
      // } else {
      //   print("No document found for user $userName.");
      // }
    } catch (e) {
      print("Error performing TF-IDF calculation and updating document: $e");
    }
  }

  void readMore(String link) async {
    print("Read More button pressed, $link might have been opened.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Back button
        ),
title:
        FutureBuilder<String>(
          future: translator
              .translate(widget.newsItem.title,
              to: globalLanguageOption)
              .then((value) => value.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Text(
                "Loading translation...",
                style: TextStyle(color: Colors.black87),
              );
            }
            if (snapshot.hasError) {
              return const Text(
                "Error translating...",
                style: TextStyle(color: Colors.red),
              );
            }
            return Text(
              snapshot.data ?? "",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            );
          },
        ),

        // title: Text(widget.newsItem.title),


      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.network(
              widget.newsItem.imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.grey.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      FutureBuilder<String>(
                        future: translator
                            .translate(widget.newsItem.title,
                            to: globalLanguageOption)
                            .then((value) => value.toString()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading translation...",
                              style: TextStyle(color: Colors.white),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Text(
                              "Error translating...",
                              style: TextStyle(color: Colors.red),
                            );
                          }
                          return Text(
                            snapshot.data ?? "",
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),

                      // Text(
                      //   widget.newsItem.title,
                      //   style: const TextStyle(
                      //     fontSize: 21,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.white,
                      //   ),
                      // ),


                      SizedBox(height: 16),

                      // Image and other content
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Image.network(
                          widget.newsItem.imageUrl,
                          height: 200,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey,
                              child: const Center(
                                child: Icon(Icons.broken_image,
                                    size: 50, color: Colors.white),
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(height: 16),

                      // Author and Date sections
                      Text(
                        "Author: ${widget.newsItem.author}",
                        style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Published: ${widget.newsItem.date}",
                        style: TextStyle(fontSize: 16, color: Colors.grey[300]),
                      ),
                      SizedBox(height: 16),

                      // Description section
                      // Text(
                      //   widget.newsItem.description,
                      //   style: TextStyle(fontSize: 14, color: Colors.white),
                      // ),

                      FutureBuilder<String>(
                        future: translator
                            .translate(widget.newsItem.description,
                            to: globalLanguageOption)
                            .then((value) => value.toString()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Text(
                              "Loading translation...",
                              style: TextStyle(color: Colors.white),
                            );
                          }
                          if (snapshot.hasError) {
                            return const Text(
                              "Error translating...",
                              style: TextStyle(color: Colors.red),
                            );
                          }
                          return Text(
                            snapshot.data ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),

                      SizedBox(height: 16),

                      // Source section
                      Text(
                        "Source: ${widget.newsItem.sourceName}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400], // Source color
                        ),
                      ),
                      SizedBox(height: 16), // Space before buttons
                      // Like Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: toggleLike,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              isLiked ? Icons.save : Icons.save_alt_outlined,
                              color: Colors.white,
                            ),
                            label: Text(
                              isLiked ? 'Saved' : 'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              openLink(widget.newsItem.link ?? "");
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Read More',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
