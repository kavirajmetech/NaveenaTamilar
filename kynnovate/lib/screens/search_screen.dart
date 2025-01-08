// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:kynnovate/Models/news_item.dart';
// import 'package:kynnovate/globals.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:xml/xml.dart' as xml;
// import 'news_details_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class SearchScreen extends StatefulWidget {
//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   late Future<List<NewsItem>> futureNewsItems;
//   bool isLoading = true;
//   String errorMessage = '';
//   final TextEditingController _searchController = TextEditingController();
//   List<NewsItem> allNewsItems = [];
//   List<NewsItem> filteredNewsItems = [];
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _text = "Press the microphone to start listening...";
//   double _confidence = 1.0;

//   Future<List<NewsItem>> fetchRssFeed(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final document = xml.XmlDocument.parse(response.body);
//         final items = document.findAllElements('item');
//         return items.map((element) => NewsItem.fromXml(element)).toList();
//       } else {
//         print(
//             'Failed to load RSS feed from $url (Status Code: ${response.statusCode})');
//         return [];
//       }
//     } catch (e) {
//       print('Error fetching RSS feed from $url: $e');
//       return [];
//     }
//   }

//   // Fetch multiple RSS feeds
//   Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
//     List<NewsItem> allNewsItems = [];
//     for (String url in urls) {
//       try {
//         final newsItems = await fetchRssFeed(url);
//         if (newsItems.isNotEmpty) {
//           allNewsItems.addAll(newsItems.take(20));
//         }
//       } catch (e) {
//         print('Error fetching from $url: $e');
//       }
//     }
//     return allNewsItems;
//   }

//   Future<void> _startListening() async {
//     bool available = await _speech.initialize(
//       onStatus: (val) => print('Status: $val'),
//       onError: (val) => print('Error: $val'),
//     );

//     if (available) {
//       setState(() => _isListening = true);
//       _speech.listen(
//         onResult: (val) => setState(() {
//           setState(() {
//             _searchController.text = val.recognizedWords;
//           });

//           if (val.hasConfidenceRating && val.confidence > 0) {
//             _confidence = val.confidence;
//           }
//         }),
//         localeId: "ta-IN", // Replace with the desired language locale
//       );
//     } else {
//       setState(() => _isListening = false);
//       print("Speech recognition is not available.");
//     }
//   }

//   void _stopListening() {
//     setState(() => _isListening = false);
//     _speech.stop();
//   }

//   Future<void> _refreshNews() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });

//     try {
//       final fetchedItems = await fetchMultipleRssFeeds([
//         'https://feeds.feedburner.com/Hindu_Tamil_tamilnadu',
//         'https://feeds.bbci.co.uk/news/world/rss.xml',
//         'https://www.thanthitv.com/feed',
//       ]);

//       setState(() {
//         allNewsItems = fetchedItems;
//         filteredNewsItems = fetchedItems;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to refresh news. Please try again later.';
//       });
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Filter news based on the search query
//   void _filterNews(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         filteredNewsItems = allNewsItems;
//       } else {
//         filteredNewsItems = allNewsItems
//             .where((item) =>
//                 item.title.toLowerCase().contains(query.toLowerCase()))
//             .toList();
//       }
//     });
//   }

//   @override
//   void initState() {
//     super.initState();
//     _refreshNews();
//     _searchController.addListener(() {
//       _filterNews(_searchController.text);
//     });
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<List<String>> fetchWords(String username) async {
//     try {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection('User')
//           .where('name', isEqualTo: username)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final docData = querySnapshot.docs.first.data() as Map<String, dynamic>;
//         return List<String>.from(docData['words'] ?? []);
//       }
//     } catch (e) {
//       print("Error fetching words: $e");
//     }
//     return [];
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Search News"),
//         titleTextStyle: TextStyle(
//             fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back,
//             size: 20,
//           ),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: errorMessage.isNotEmpty
//           ? _buildErrorWidget()
//           : Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     controller: _searchController,
//                     decoration: InputDecoration(
//                       hintText: 'Search news by title...',
//                       hintStyle: const TextStyle(color: Colors.grey),
//                       filled: true, // Background color
//                       fillColor: Colors.grey[200], // Light grey background
//                       border: OutlineInputBorder(
//                         borderRadius:
//                             BorderRadius.circular(30.0), // Rounded corners
//                         borderSide: BorderSide.none, // No visible border
//                       ),
//                       prefixIcon: const Icon(Icons.search, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: RefreshIndicator(
//                     onRefresh: _refreshNews,
//                     child: isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : _buildNewsList(filteredNewsItems),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildErrorWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.error_outline, size: 48, color: Colors.red),
//           const SizedBox(height: 16),
//           Text(
//             errorMessage,
//             textAlign: TextAlign.center,
//             style: const TextStyle(fontSize: 16),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _refreshNews,
//             child: const Text('Try Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNewsList(List<NewsItem> newsItems) {
//     return FutureBuilder<List<String>>(
//       future: fetchWords(globalUsername ?? "Kaviyarasu S"),
//       builder: (context, wordsSnapshot) {
//         if (wordsSnapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (wordsSnapshot.hasError) {
//           return const Center(child: Text("Error loading keywords"));
//         } else if (!wordsSnapshot.hasData || wordsSnapshot.data!.isEmpty) {
//           return ListView.builder(
//             itemCount: newsItems.length,
//             itemBuilder: (context, index) {
//               final newsItem = newsItems[index];
//               return _buildNewsCard(newsItem);
//             },
//           );
//         }

//         final words = wordsSnapshot.data!;

//         return ListView.builder(
//           itemCount: newsItems.length,
//           itemBuilder: (context, index) {
//             final newsItem = newsItems[index];
//             final containsKeywords = words.any((word) =>
//                 newsItem.title.contains(word) ||
//                 newsItem.description.contains(word));

//             return Card(
//               margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (containsKeywords) // Add "Recommended" row if keywords match
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(8),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[400],
//                         borderRadius: BorderRadius.only(
//                           topLeft:
//                               Radius.circular(15), // Round the top-left corner
//                           topRight:
//                               Radius.circular(15), // Round the top-right corner
//                         ),
//                       ),
//                       child: const Text(
//                         "Recommended",
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   _buildNewsCard(newsItem),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildNewsCard(NewsItem newsItem) {
//     return ListTile(
//       leading: SizedBox(
//         width: 100,
//         child: _buildNewsImage(newsItem.imageUrl, 60.0),
//       ),
//       title: Text(
//         newsItem.title,
//         maxLines: 3,
//         overflow: TextOverflow.ellipsis,
//       ),
//       subtitle: Text(
//         newsItem.date,
//         maxLines: 2,
//         overflow: TextOverflow.ellipsis,
//       ),
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => NewsDetailScreen(newsItem: newsItem),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildNewsImage(String imageUrl, double height) {
//     return imageUrl.isNotEmpty
//         ? Image.network(
//             imageUrl,
//             width: double.infinity,
//             height: height,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 height: height,
//                 color: Colors.grey[300],
//                 child: const Icon(Icons.image_not_supported),
//               );
//             },
//             loadingBuilder: (context, child, loadingProgress) {
//               if (loadingProgress == null) return child;
//               return Container(
//                 height: height,
//                 color: Colors.grey[200],
//                 child: const Center(child: CircularProgressIndicator()),
//               );
//             },
//           )
//         : Container(
//             height: height,
//             color: Colors.grey[300],
//             child: const Icon(Icons.image_not_supported),
//           );
//   }
// }

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/globals.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:xml/xml.dart' as xml;
import 'news_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late Future<List<NewsItem>> futureNewsItems;
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();
  List<NewsItem> allNewsItems = [];
  List<NewsItem> filteredNewsItems = [];
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the microphone to start listening...";
  double _confidence = 1.0;

  Future<List<NewsItem>> fetchRssFeed(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        return items.map((element) => NewsItem.fromXml(element)).toList();
      } else {
        print(
            'Failed to load RSS feed from $url (Status Code: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      print('Error fetching RSS feed from $url: $e');
      return [];
    }
  }

  // Fetch multiple RSS feeds
  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    for (String url in urls) {
      try {
        final newsItems = await fetchRssFeed(url);
        if (newsItems.isNotEmpty) {
          allNewsItems.addAll(newsItems.take(20));
        }
      } catch (e) {
        print('Error fetching from $url: $e');
      }
    }
    return allNewsItems;
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (val) => print('Status: $val'),
      onError: (val) => print('Error: $val'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (val) => setState(() {
          _searchController.text = val.recognizedWords;
          if (val.hasConfidenceRating && val.confidence > 0) {
            _confidence = val.confidence;
          }
        }),
        localeId: "ta-IN", // Replace with the desired language locale for Tamil
      );
    } else {
      setState(() => _isListening = false);
      print("Speech recognition is not available.");
    }
  }

  void _stopListening() {
    setState(() => _isListening = false);
    _speech.stop();
  }

  Future<void> _refreshNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final fetchedItems = await fetchMultipleRssFeeds([
        'https://feeds.feedburner.com/Hindu_Tamil_tamilnadu',
        'https://feeds.bbci.co.uk/news/world/rss.xml',
        'https://www.thanthitv.com/feed',
      ]);

      setState(() {
        allNewsItems = fetchedItems;
        filteredNewsItems = fetchedItems;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to refresh news. Please try again later.';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Filter news based on the search query
  void _filterNews(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredNewsItems = allNewsItems;
      } else {
        filteredNewsItems = allNewsItems
            .where((item) =>
                item.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _refreshNews();
    _searchController.addListener(() {
      _filterNews(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchWords(String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('name', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docData = querySnapshot.docs.first.data() as Map<String, dynamic>;
        return List<String>.from(docData['words'] ?? []);
      }
    } catch (e) {
      print("Error fetching words: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search News"),
        titleTextStyle: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w400, color: Colors.black),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search news by title...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshNews,
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildNewsList(filteredNewsItems),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startListening,
        child: Icon(
          _isListening ? Icons.mic_off : Icons.mic,
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshNews,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<NewsItem> newsItems) {
    return FutureBuilder<List<String>>(
      future: fetchWords(globalUsername ?? "Kaviyarasu S"),
      builder: (context, wordsSnapshot) {
        if (wordsSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (wordsSnapshot.hasError) {
          return const Center(child: Text("Error loading keywords"));
        } else if (!wordsSnapshot.hasData || wordsSnapshot.data!.isEmpty) {
          return ListView.builder(
            itemCount: newsItems.length,
            itemBuilder: (context, index) {
              final newsItem = newsItems[index];
              return _buildNewsCard(newsItem);
            },
          );
        }

        final words = wordsSnapshot.data!;

        return ListView.builder(
          itemCount: newsItems.length,
          itemBuilder: (context, index) {
            final newsItem = newsItems[index];
            final containsKeywords = words.any((word) =>
                newsItem.title.contains(word) ||
                newsItem.description.contains(word));

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (containsKeywords)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Recommended",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  _buildNewsCard(newsItem),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNewsCard(NewsItem newsItem) {
    return ListTile(
      leading: SizedBox(
        width: 100,
        child: _buildNewsImage(newsItem.imageUrl, 60.0),
      ),
      title: Text(
        newsItem.title,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        newsItem.date,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsItem: newsItem),
          ),
        );
      },
    );
  }

  Widget _buildNewsImage(String imageUrl, double height) {
    return imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            height: height,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
          )
        : const Icon(Icons.image_not_supported);
  }
}
