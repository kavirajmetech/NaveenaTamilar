// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'package:xml/xml.dart' as xml;
// // import 'package:kynnovate/Models/news_item.dart';

// // class CategoryPage extends StatelessWidget {
// //   final String tag;

// //   CategoryPage({required this.tag});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Category: $tag'),
// //       ),
// //       body: Center(
// //         child: Text('News for $tag'),
// //       ),
// //     );
// //   }
// // }

// // class _CategoryPageState extends State<CategoryPage> {
// //   List<NewsItem> newsItems = [];
// //   bool isLoading = true;

// //   @override
// //   void initState() {
// //     super.initState();
// //     loadNewsForTag(widget.tag);
// //   }

// //   Future<void> loadNewsForTag(String tag) async {
// //     try {
// //       // Load RSS URLs from JSON
// //       String jsonString = await DefaultAssetBundle.of(context).loadString('assets/rssList.json');
// //       Map<String, dynamic> rssData = json.decode(jsonString);

// //       List<String> urls = getUrlsForTag(tag, rssData);

// //       if (urls.isNotEmpty) {
// //         List<NewsItem> fetchedNews = await fetchMultipleRssFeeds(urls);
// //         setState(() {
// //           newsItems = fetchedNews;
// //           isLoading = false;
// //         });
// //       } else {
// //         throw Exception('No RSS URLs found for tag: $tag');
// //       }
// //     } catch (e) {
// //       print('Error loading news for tag $tag: $e');
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   List<String> getUrlsForTag(String tag, Map<String, dynamic> rssData) {
// //     List<String> urls = [];

// //     if (rssData['categories'][tag] is List) {
// //       urls = List<String>.from(rssData['categories'][tag]);
// //     } else if (rssData['categories'][tag] is Map) {
// //       Map<String, dynamic> subcategories = rssData['categories'][tag];
// //       for (var subList in subcategories.values) {
// //         urls.addAll(List<String>.from(subList));
// //       }
// //     }

// //     return urls;
// //   }

// //   Future<List<NewsItem>> fetchRssFeed(String url) async {
// //     try {
// //       final response = await http.get(Uri.parse(url));
// //       if (response.statusCode == 200) {
// //         final document = xml.XmlDocument.parse(response.body);
// //         final items = document.findAllElements('item');
// //         return items.map((element) => NewsItem.fromXml(element)).toList();
// //       } else {
// //         print('Failed to load RSS feed from $url (Status Code: ${response.statusCode})');
// //         return [];
// //       }
// //     } catch (e) {
// //       print('Error fetching RSS feed from $url: $e');
// //       return [];
// //     }
// //   }

// //   Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
// //     List<NewsItem> allNewsItems = [];
// //     List<String> failedUrls = [];

// //     for (String url in urls) {
// //       try {
// //         final newsItems = await fetchRssFeed(url);
// //         if (newsItems.isNotEmpty) {
// //           allNewsItems.addAll(newsItems);
// //         } else {
// //           failedUrls.add(url);
// //         }
// //       } catch (e) {
// //         failedUrls.add(url);
// //         print('Error fetching from $url: $e');
// //       }
// //     }

// //     if (allNewsItems.isEmpty && failedUrls.isNotEmpty) {
// //       throw Exception('Failed to fetch news from any source');
// //     }

// //     return allNewsItems;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(widget.tag),
// //       ),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator())
// //           : newsItems.isEmpty
// //               ? const Center(child: Text('No news available'))
// //               : ListView.builder(
// //                   itemCount: newsItems.length,
// //                   itemBuilder: (context, index) {
// //                     final item = newsItems[index];
// //                     return ListTile(
// //                       leading: item.imageUrl != null
// //                           ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
// //                           : const Icon(Icons.image, size: 50),
// //                       title: Text(item.title ?? 'No Title'),
// //                       subtitle: Text(item.description ?? 'No Description'),
// //                       trailing: const Icon(Icons.arrow_forward),
// //                       onTap: () {
// //                         // Handle navigation or open link
// //                       },
// //                     );
// //                   },
// //                 ),
// //     );
// //   }
// // }

// import 'dart:convert';
// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:http/http.dart' as http;
// import 'package:kynnovate/Models/news_item.dart';
// import 'package:xml/xml.dart' as xml;
// import 'category_page.dart';
// import 'latest_news_page.dart';
// import 'location_page.dart';
// import 'news_details_screen.dart';
// import 'dart:async';

// import 'todays_page.dart';

// class CategoryPage extends StatefulWidget {
//   final String category;

//   // Constructor for CategoryPage
//   CategoryPage({required this.category});

//   @override
//   _CategoryPageState createState() => _CategoryPageState();
// }

// class _CategoryPageState extends State<CategoryPage> {
//   final categoryList = {
//     'Politics': [
//       "https://beta.dinamani.com/api/v1/collections/latest-news.rss",
//       "https://www.wahsarkar.com/feed/"
//     ],
//     'Sports': [
//       "https://tamil.news18.com/commonfeeds/v1/tam/rss/sports/cricket.xml"
//     ],
//     'Entertainment': [
//       "https://www.vikatan.com/stories.rss?section-id=8956&time-period=last-24-hours",
//       "https://www.vikatan.com/api/v1/collections/kollywood-entertainment.rss?&time-period=last-24-hours"
//     ],
//     'Business': [
//       "https://tamil.news18.com/commonfeeds/v1/tam/rss/ariyalur-district.xml"
//           "https://www.vikatan.com/stories.rss?section=business&time-period=last-24-hours"
//     ],
//     "World": [
//       "https://www.vikatan.com/api/v1/collections/international.rss?&time-period=last-24-hours",
//       "https://www.news18.com/commonfeeds/v1/eng/rss/world.xml",
//       "https://www.indiatoday.in/rss/1206577",
//       "https://timesofindia.indiatimes.com/rssfeeds/296589292.cms",
//       "https://timesofindia.indiatimes.com/rssfeeds/296589292.cms"
//     ]
//   };
//   late Future<List<NewsItem>> futureNewsItems;
//   late Timer _timer;
//   bool isLoading = true;
//   String errorMessage = '';
//   late ScrollController
//       _scrollController; // Scroll controller for auto-scrolling

//   // Fetch data method
//   Future<List<NewsItem>> fetchRssFeed(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       final decodedBody = utf8.decode(response.bodyBytes);
//       if (response.statusCode == 200) {
//         final document = xml.XmlDocument.parse(decodedBody);
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
//     List<String> failedUrls = [];

//     for (String url in urls) {
//       try {
//         final newsItems = await fetchRssFeed(url);
//         if (newsItems.isNotEmpty) {
//           allNewsItems.addAll(newsItems);
//         } else {
//           failedUrls.add(url);
//         }
//       } catch (e) {
//         failedUrls.add(url);
//         print('Error fetching from $url: $e');
//       }
//     }

//     if (allNewsItems.isEmpty && failedUrls.isNotEmpty) {
//       throw Exception('Failed to fetch news from any source');
//     }

//     return allNewsItems;
//   }

//   // Refresh method to reload data
//   Future<void> _refreshNews() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = '';
//     });

//     try {
//       futureNewsItems = fetchMultipleRssFeeds(
//           categoryList[widget.category] == null
//               ? ['https://www.dinakaran.com/feed/']
//               : categoryList[widget.category]!);
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

//   @override
//   void initState() {
//     super.initState();
//     _refreshNews();
//     _scrollController = ScrollController();

//     // Set up the timer for automatic scrolling
//     _timer = Timer.periodic(Duration(seconds: 3), (timer) {
//       if (_scrollController.hasClients) {
//         double maxScroll = _scrollController.position.maxScrollExtent;
//         double currentScroll = _scrollController.position.pixels;

//         // If the scroll position has reached the maximum, reset to the beginning
//         if (currentScroll == maxScroll) {
//           _scrollController.jumpTo(0);
//         } else {
//           // Scroll by a certain amount to the right
//           _scrollController.animateTo(
//             currentScroll + 360.0,
//             duration: Duration(seconds: 1),
//             curve: Curves.easeInOut,
//           );
//         }
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     _scrollController.dispose(); // Dispose of the scroll controller
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: errorMessage.isNotEmpty
//           ? _buildErrorWidget()
//           : RefreshIndicator(
//               onRefresh: _refreshNews,
//               child: ListView(
//                 children: [
//                   _buildSectionHeader('Categories'),
//                   _buildCategories(),
//                   _buildSectionHeader(widget.category),
//                   _buildAllNews(),
//                 ],
//               ),
//             ),
//     );
//   }

//   // Error widget
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

//   Widget _buildNewsItem(NewsItem item) {
//     double boxWidth = 350; // Adjust this to change the width of the box

//     return GestureDetector(
//       onTap: () {
//         // Navigate to NewsDetailScreen and pass the NewsItem
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => NewsDetailScreen(newsItem: item),
//           ),
//         );
//       },
//       child: Card(
//         margin: EdgeInsets.all(8.0),
//         child: Stack(
//           children: [
//             // Image with adjustable width and BoxFit.cover
//             Image.network(
//               item.imageUrl,
//               width: boxWidth, // Adjusted width
//               height: 250, // Fixed height
//               fit: BoxFit.cover, // Ensure the image covers the container
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   color: Colors.grey[300], // Placeholder in case of error
//                   height: 250,
//                   width: boxWidth,
//                   child: const Icon(Icons.image_not_supported),
//                 );
//               },
//               loadingBuilder: (context, child, loadingProgress) {
//                 if (loadingProgress == null) return child;
//                 return Container(
//                   color: Colors.grey[200], // Placeholder while loading
//                   height: 250,
//                   width: boxWidth,
//                   child: const Center(child: CircularProgressIndicator()),
//                 );
//               },
//             ),
//             // Text overlay with gradient background at the bottom
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 padding: EdgeInsets.all(8.0),
//                 width: boxWidth, // Ensure overlay matches width of the image
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                     colors: [
//                       Colors.transparent, // Transparent at the top
//                       Colors.grey.withOpacity(0.7), // Greyish at the bottom
//                     ],
//                   ),
//                 ),
//                 child: Text(
//                   item.title.length > 50
//                       ? "${item.title.substring(0, 50)}..." // Truncate text after 2 lines
//                       : item.title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16.0,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   maxLines: 2, // Limit the text to 2 lines
//                   softWrap:
//                       true, // Ensure it wraps to the next line if necessary
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build all news widget
//   Widget _buildAllNews() {
//     return FutureBuilder<List<NewsItem>>(
//       future: futureNewsItems,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return _buildSectionError(widget.category);
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildEmptySection(widget.category);
//         }
//         return _buildNewsList(snapshot.data!);
//       },
//     );
//   }

//   Widget _buildSectionError(String section) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           const Icon(Icons.error_outline, color: Colors.orange),
//           const SizedBox(height: 8),
//           Text(
//             'Unable to load $section',
//             style: const TextStyle(color: Colors.red),
//           ),
//           TextButton(
//             onPressed: _refreshNews,
//             child: const Text('Retry'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmptySection(String section) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           const Icon(Icons.inbox, color: Colors.grey),
//           const SizedBox(height: 8),
//           Text('No $section available'),
//         ],
//       ),
//     );
//   }

//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }

//   // Widget _buildHorizontalList(List<NewsItem> newsItems) {
//   //   return SizedBox(
//   //     height: 150,
//   //     child: ListView.builder(
//   //       scrollDirection: Axis.horizontal,
//   //       itemCount: newsItems.length,
//   //       itemBuilder: (context, index) {
//   //         final newsItem = newsItems[index];
//   //         return Container(
//   //           width: 200,
//   //           margin: const EdgeInsets.only(left: 16),
//   //           child: Card(
//   //             elevation: 5,
//   //             child: Column(
//   //               crossAxisAlignment: CrossAxisAlignment.start,
//   //               children: [
//   //                 _buildNewsImage(newsItem.imageUrl, 100.0),
//   //                 Padding(
//   //                   padding: const EdgeInsets.all(8.0),
//   //                   child: Text(
//   //                     newsItem.title,
//   //                     maxLines: 2,
//   //                     overflow: TextOverflow.ellipsis,
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         );
//   //       },
//   //     ),
//   //   );
//   // }

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

//   Widget _buildCategories() {
//     final categories = [
//       'Politics',
//       'Sports',
//       'Entertainment',
//       'Business',
//       'World'
//     ];
//     final categoriesImages = [
//       'politics.png',
//       'sports.png',
//       'entertainment.png',
//       'business.png',
//       'world.png'
//     ];

//     return SizedBox(
//       height: 100,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               // Navigate to CategoryPage with the selected category
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       CategoryPage(category: categories[index]),
//                 ),
//               );
//             },
//             child: Container(
//               width: 100,
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 30,
//                     backgroundImage:
//                         AssetImage('assets/images/${categoriesImages[index]}'),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     categories[index],
//                     style: TextStyle(
//                       fontWeight: widget.category == categories[index]
//                           ? FontWeight.bold
//                           : FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildNewsList(List<NewsItem> newsItems) {
//     return ListView.builder(
//       shrinkWrap: true,
//       //physics: const NeverScrollableScrollPhysics(),
//       itemCount: newsItems.length,
//       itemBuilder: (context, index) {
//         final newsItem = newsItems[index];
//         return Card(
//           margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: ListTile(
//             leading: SizedBox(
//               width: 100,
//               child: _buildNewsImage(newsItem.imageUrl, 60.0),
//             ),
//             title: Text(
//               newsItem.title,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             subtitle: Text(
//               newsItem.date,
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => NewsDetailScreen(newsItem: newsItem),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }
// }

import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/landingpage.dart';
import 'package:xml/xml.dart' as xml;
import 'category_page.dart';
import 'latest_news_page.dart';
import 'location_page.dart';
import 'news_details_screen.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'news_list_screen.dart';
import 'todays_page.dart';

class CategoryPage extends StatefulWidget {
  final String category;

  // Constructor for CategoryPage
  CategoryPage({required this.category});

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final categoryList = {
    'Politics': ["https://www.news18.com/commonfeeds/v1/eng/rss/politics.xml"],
    'Sports': [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/sports/cricket.xml",
      "https://www.news18.com/commonfeeds/v1/eng/rss/sports.xml",
      "https://www.news18.com/commonfeeds/v1/eng/rss/football.xml",
      "https://www.indiatoday.in/rss/1206550",
      "https://timesofindia.indiatimes.com/rssfeeds/4719148.cms",
      "https://timesofindia.indiatimes.com/rssfeeds/54829575.cms",
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/sports.xml",
      "https://tamil.hindustantimes.com/rss/sports"
    ],
    'Entertainment': [
      // "https://www.vikatan.com/stories.rss?section-id=8956&time-period=last-24-hours",
      "https://timesofindia.indiatimes.com/rssfeeds/1081479906.cms",
      "https://timesofindia.indiatimes.com/rssfeedsvideo/3812908.cms",
      "https://tamil.hindustantimes.com/rss/entertainment"
    ],
    'Business': [
      "https://www.vikatan.com/stories.rss?section=business&time-period=last-24-hours",
      "https://www.indiatoday.in/rss/1206513",
      "https://timesofindia.indiatimes.com/rssfeedsvideo/3813458.cms"
    ],
    "World": [
      "https://www.vikatan.com/api/v1/collections/international.rss?&time-period=last-24-hours",
      "https://www.news18.com/commonfeeds/v1/eng/rss/world.xml",
      "https://www.indiatoday.in/rss/1206577",
      "https://timesofindia.indiatimes.com/rssfeeds/296589292.cms",
      "https://timesofindia.indiatimes.com/rssfeeds/296589292.cms"
    ]
  };
  late Future<List<NewsItem>> futureNewsItems;
  bool isLoading = true;
  String errorMessage = '';
  int _currentPage = 1; // Track the current page
  bool _isFetchingMore = false; // Prevent multiple fetches
  List<NewsItem> _newsItems = []; // Store fetched news items

  late ScrollController
      _scrollController; // Scroll controller for auto-scrolling

  // Fetch data method
  Future<List<NewsItem>> fetchRssFeed(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final deco = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(deco);
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

  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls,
      {int limit = 15, int page = 1}) async {
    List<NewsItem> allNewsItems = [];
    List<String> failedUrls = [];
    int start = (page - 1) * limit;
    int end = start + limit;

    for (String url in urls) {
      try {
        final newsItems = await fetchRssFeed(url);
        if (newsItems.isNotEmpty) {
          allNewsItems.addAll(newsItems);
        } else {
          failedUrls.add(url);
        }
      } catch (e) {
        failedUrls.add(url);
        print('Error fetching from $url: $e');
      }
    }

    if (allNewsItems.isEmpty && failedUrls.isNotEmpty) {
      throw Exception('Failed to fetch news from any source');
    }

    // Return only the paginated items
    return allNewsItems.sublist(
        start, end > allNewsItems.length ? allNewsItems.length : end);
  }

  Future<List<NewsItem>> _refreshNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      _currentPage = 1; // Reset pagination
      _newsItems.clear(); // Clear existing data
    });

    try {
      final items = await fetchMultipleRssFeeds(
        categoryList[widget.category] ?? ['https://www.dinakaran.com/feed/'],
        page: _currentPage,
      );
      setState(() {
        _newsItems.addAll(items);
      });
      return items; // Return the fetched items
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to refresh news. Please try again later.';
      });
      return [];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNews() async {
    if (_isFetchingMore) return; // Prevent multiple fetches
    setState(() {
      _isFetchingMore = true;
    });

    try {
      _currentPage++; // Increment the page number
      final items = await fetchMultipleRssFeeds(
        categoryList[widget.category] ?? ['https://www.dinakaran.com/feed/'],
        page: _currentPage,
      );
      setState(() {
        _newsItems.addAll(items); // Append new items to the list
      });
    } catch (e) {
      print('Error loading more news: $e');
    } finally {
      setState(() {
        _isFetchingMore = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    futureNewsItems = _refreshNews();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreNews(); // Fetch more news when near the bottom
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: errorMessage.isNotEmpty
          ? _buildErrorWidget()
          : RefreshIndicator(
              onRefresh: _refreshNews,
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      HomePage(toggleTheme: () {})),
                            );
                            print("Navigation to NewsListScreen clicked");
                          },
                          icon: const Icon(Icons.arrow_back),
                          iconSize: 25,
                        ),
                        Text(
                          'Categories',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  // _buildSectionHeader('Categories'),
                  _buildCategories(),
                  _buildSectionHeader(widget.category),
                  _buildAllNews(),
                ],
              ),
            ),
    );
  }

  // Error widget
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

  Widget _buildNewsItem(NewsItem item) {
    double boxWidth = 350; // Adjust this to change the width of the box

    return GestureDetector(
      onTap: () {
        // Navigate to NewsDetailScreen and pass the NewsItem
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(newsItem: item),
          ),
        );
      },
      child: Card(
        margin: EdgeInsets.all(8.0),
        child: Stack(
          children: [
            // Image with adjustable width and BoxFit.cover
            Image.network(
              item.imageUrl,
              width: boxWidth, // Adjusted width
              height: 250, // Fixed height
              fit: BoxFit.cover, // Ensure the image covers the container
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300], // Placeholder in case of error
                  height: 250,
                  width: boxWidth,
                  child: const Icon(Icons.image_not_supported),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200], // Placeholder while loading
                  height: 250,
                  width: boxWidth,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
            // Text overlay with gradient background at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                width: boxWidth, // Ensure overlay matches width of the image
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent, // Transparent at the top
                      Colors.grey.withOpacity(0.7), // Greyish at the bottom
                    ],
                  ),
                ),
                child: Text(
                  item.title.length > 50
                      ? "${item.title.substring(0, 50)}..." // Truncate text after 2 lines
                      : item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2, // Limit the text to 2 lines
                  softWrap:
                      true, // Ensure it wraps to the next line if necessary
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllNews() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    } else if (errorMessage.isNotEmpty) {
      return _buildSectionError(widget.category);
    } else if (_newsItems.isEmpty) {
      return _buildEmptySection(widget.category);
    }

    return _buildNewsList(_newsItems);
  }

  Widget _buildSectionError(String section) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.error_outline, color: Colors.orange),
          const SizedBox(height: 8),
          Text(
            'Unable to load $section',
            style: const TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: _refreshNews,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySection(String section) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Icon(Icons.inbox, color: Colors.grey),
          const SizedBox(height: 8),
          Text('No $section available'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsImage(String imageUrl, double height) {
    return imageUrl.isNotEmpty
        ? Image.network(
            imageUrl,
            width: double.infinity,
            height: height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: height,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: height,
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
          )
        : Container(
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported),
          );
  }

  Widget _buildCategories() {
    final categories = ['Politics', 'Sports', 'Entertainment', 'Business', 'World'];
    final categoriesImages = [
      'politics.png',
      'sports.png',
      'entertainment.png',
      'business.png',
      'world.png'
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to CategoryPage with the selected category
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CategoryPage(category: categories[index]),
                ),
              );
            },
            child: Container(
              width: 100,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage:
                        AssetImage('assets/images/${categoriesImages[index]}'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    categories[index],
                    style: TextStyle(
                      fontWeight: widget.category == categories[index]
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsList(List<NewsItem> newsItems) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: newsItems.length,
      itemBuilder: (context, index) {
        final newsItem = newsItems[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: SizedBox(
              width: 100,
              child: _buildNewsImage(newsItem.imageUrl, 60.0),
            ),
            title: Text(
              newsItem.title,
              maxLines: 2,
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
          ),
        );
      },
    );
  }
}
