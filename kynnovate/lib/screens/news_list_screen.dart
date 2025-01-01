// import 'dart:ffi';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:http/http.dart' as http;
// import 'package:xml/xml.dart' as xml;
// import 'category_page.dart';
// import 'latest_news_page.dart';
// import 'location_page.dart';
// import 'news_details_screen.dart';
// import 'package:kynnovate/Models/news_item.dart';
// import 'dart:async';

// import 'todays_page.dart';

// class NewsListScreen extends StatefulWidget {
//   @override
//   _NewsListScreenState createState() => _NewsListScreenState();
// }

// class _NewsListScreenState extends State<NewsListScreen> {
//   late Future<List<NewsItem>> futureNewsItems;
//   late Future<List<NewsItem>> latestItems;
//   late Timer _timer;
//   bool isLoading = true;
//   String errorMessage = '';
//   late ScrollController
//       _scrollController; // Scroll controller for auto-scrolling

//   // Fetch data method
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
//       latestItems = fetchMultipleRssFeeds(["https://www.dinakaran.com/feed/"]);
//       futureNewsItems = fetchMultipleRssFeeds([
//         'https://www.dinakaran.com/feed/',
//         'https://timesofindia.indiatimes.com/rss.cms',
//         'https://www.thanthitv.com/feed',
//         'https://timesofindia.indiatimes.com/rssfeeds/1221656.cms',
//         'https://www.indiatoday.in/rss',
//         'https://feeds.bbci.co.uk/news/world/rss.xml',
//         'https://www.hindutamil.in/rss',
//         'https://www.dinamani.com/rss',
//         'https://feeds.nbcnews.com/nbcnews/public/news',
//       ]);
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
//                   _buildSectionHeader('Latest'),
//                   _buildLatestNews(),
//                   _buildSectionHeader('Categories'),
//                   _buildCategories(),
//                   _buildSectionHeader('Location'),
//                   _buildLocations(),
//                   _buildSectionHeader('Today\'s'),
//                   _buildAllNews(),
//                 ],
//               ),
//             ),
//       // bottomNavigationBar: BottomNavigationBar(
//       //   items: const [
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.home),
//       //       label: 'Home',
//       //       backgroundColor: Colors.blueGrey,
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.search),
//       //       label: 'Search',
//       //       backgroundColor: Colors.blueGrey,
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.favorite),
//       //       label: 'Favorites',
//       //       backgroundColor: Colors.blueGrey,
//       //     ),
//       //     BottomNavigationBarItem(
//       //       icon: Icon(Icons.person),
//       //       label: 'Profile',
//       //       backgroundColor: Colors.blueGrey,
//       //     ),
//       //   ],
//       //   selectedItemColor: const Color.fromARGB(255, 0, 0, 0),
//       //   unselectedItemColor: const Color.fromARGB(255, 91, 91, 91),
//       //   showSelectedLabels: true,
//       //   showUnselectedLabels: true,
//       //   type: BottomNavigationBarType.fixed,
//       // ),
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
//                   style: TextStyle(
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

//   // Build latest news widget
//   Widget _buildLatestNews() {
//     return FutureBuilder<List<NewsItem>>(
//       future: latestItems,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: CircularProgressIndicator(),
//             ),
//           );
//         } else if (snapshot.hasError) {
//           return _buildSectionError('Latest News');
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildEmptySection('Latest News');
//         }

//         final items = snapshot.data!.take(5).toList();

//         return SizedBox(
//           height: 250, // Keep the height fixed
//           child: ListView.builder(
//             controller: _scrollController,
//             scrollDirection: Axis.horizontal,
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               return _buildNewsItem(items[index]);
//             },
//           ),
//         );
//       },
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
//           return _buildSectionError('Today\'s News');
//         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//           return _buildEmptySection('Today\'s News');
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
//           TextButton(
//             onPressed: () {
//               if (title == 'Latest') {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => LatestNewsPage()));
//               } else if (title == 'Categories') {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => CategoryPage(tag: 'Politics')));
//               } else if (title == 'Location') {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) =>
//                             LocationPage(locationTag: 'Chennai')));
//               } else if (title == 'Today\'s') {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => TodaysPage()));
//               }
//             },
//             child: const Text('See All'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHorizontalList(List<NewsItem> newsItems) {
//     return SizedBox(
//       height: 150,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: newsItems.length,
//         itemBuilder: (context, index) {
//           final newsItem = newsItems[index];
//           return Container(
//             width: 200,
//             margin: const EdgeInsets.only(left: 16),
//             child: Card(
//               elevation: 5,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildNewsImage(newsItem.imageUrl, 100.0),
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       newsItem.title,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
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
//     final categories = ['Politics', 'Sports', 'Entertainment', 'Business'];
//     final categoriesImages = [
//       'politics.png',
//       'sports.png',
//       'entertainment.png',
//       'business.png',
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
//                   builder: (context) => CategoryPage(tag: categories[index]),
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
//                   Text(categories[index]),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildLocations() {
//     final locations = [
//       'Chennai',
//       'Cuddalore',
//       'Thiruvannamalai',
//       'Sivakasi',
//       'Pondicherry',
//     ];

//     return SizedBox(
//       height: 100,
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: locations.length,
//         itemBuilder: (context, index) {
//           return GestureDetector(
//             onTap: () {
//               // Navigate to LocationPage with the selected location
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) =>
//                       LocationPage(locationTag: locations[index]),
//                 ),
//               );
//             },
//             child: Container(
//               width: 100,
//               child: Column(
//                 children: [
//                   Icon(
//                     Icons.location_on,
//                     size: 40,
//                     color: const Color.fromARGB(255, 46, 78, 255),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     locations[index],
//                     style: const TextStyle(
//                         fontSize: 12, fontWeight: FontWeight.w600),
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
//       physics: const NeverScrollableScrollPhysics(),
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
//             onTap: () {
//               // Handle news item tap
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
import 'package:kynnovate/config.dart';
import 'package:kynnovate/globals.dart';
import 'package:xml/xml.dart' as xml;
import 'category_page.dart';
import 'latest_news_page.dart';
import 'location_page.dart';
import 'news_details_screen.dart';
// import 'news_item.dart';
import 'dart:async';

import 'todays_page.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<NewsItem>> futureNewsItems;
  late Future<List<NewsItem>> latestItems;
  late Timer _timer;
  bool isLoading = true;
  String errorMessage = '';
  late ScrollController
      _scrollController; // Scroll controller for auto-scrolling

  // Fetch data method
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
    List<String> failedUrls = [];

    for (String url in urls) {
      try {
        final newsItems = await fetchRssFeed(url);
        if (newsItems.isNotEmpty) {
          allNewsItems.addAll(newsItems.take(5));
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

    return allNewsItems;
  }

  // Refresh method to reload data
  Future<void> _refreshNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      latestItems = fetchMultipleRssFeeds(["https://www.dinakaran.com/feed/"]);
      futureNewsItems = fetchMultipleRssFeeds([
        'https://feeds.feedburner.com/Hindu_Tamil_tamilnadu', //perfect
        'https://feeds.bbci.co.uk/news/world/rss.xml', //perfect
        'https://www.thanthitv.com/feed', //not contains desc
        'https://www.indiatoday.in/rss/home', // no desc
        'https://www.dinamani.com/rss',
        'https://feeds.nbcnews.com/nbcnews/public/news',
        'https://www.dinakaran.com/feed/',
        'https://timesofindia.indiatimes.com/rss.cms',
        'https://www.thanthitv.com/feed',
        'https://timesofindia.indiatimes.com/rssfeeds/1221656.cms',
        'https://www.indiatoday.in/rss',
        'https://feeds.bbci.co.uk/news/world/rss.xml',
        'https://www.hindutamil.in/rss',
        'https://www.dinamani.com/rss',
        'https://feeds.nbcnews.com/nbcnews/public/news',
        'https://tamil.oneindia.com/rss/feeds/tamil-technology-fb.xml',
        'https://tamil.oneindia.com/rss/feeds/tamil-weather-fb.xml',
        'https://tamil.oneindia.com/rss/feeds/tamil-news-fb.xml',
        'https://tamil.news18.com/commonfeeds/v1/tam/rss/sports/cricket.xml',
        'https://tamil.news18.com/commonfeeds/v1/tam/rss/virudhunagar-district.xml',
        'https://tamil.news18.com/commonfeeds/v1/tam/rss/chennai-district.xml',
      ]);
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

  @override
  void initState() {
    super.initState();
    _refreshNews();
    _scrollController = ScrollController();

    // Set up the timer for automatic scrolling
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;

        // If the scroll position has reached the maximum, reset to the beginning
        if (currentScroll == maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          // Scroll by a certain amount to the right
          _scrollController.animateTo(
            currentScroll + 360.0,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose(); // Dispose of the scroll controller
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
                  _buildSectionHeader('Latest'),
                  _buildLatestNews(),
                  _buildSectionHeader('Categories'),
                  _buildCategories(),
                  _buildSectionHeader('Location'),
                  _buildLocations(),
                  _buildSectionHeader('Today\'s'),
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

  // Build latest news widget
  Widget _buildLatestNews() {
    return FutureBuilder<List<NewsItem>>(
      future: latestItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildSectionError('Latest News');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection('Latest News');
        }

        final items = snapshot.data!.take(5).toList();

        return SizedBox(
          height: 250, // Keep the height fixed
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildNewsItem(items[index]);
            },
          ),
        );
      },
    );
  }

  // Build all news widget
  Widget _buildAllNews() {
    return FutureBuilder<List<NewsItem>>(
      future: futureNewsItems,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return _buildSectionError('Today\'s News1');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection('Today\'s News2');
        }
        return _buildNewsList(snapshot.data!);
      },
    );
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
            () {
              if (title == 'Latest') {
                return latest[globalLanguageOption] ?? 'Latest';
              } else if (title == 'Categories') {
                return categories[globalLanguageOption] ?? 'Categories';
              } else if (title == 'Location') {
                return location[globalLanguageOption] ?? 'Location';
              } else {
                return today[globalLanguageOption] ?? 'Today\'s';
              }
            }(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {
              if (title == 'Latest') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LatestNewsPage()));
              } else if (title == 'Categories') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            CategoryPage(category: 'Politics')));
              } else if (title == 'Location') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            LocationPage(locationTag: 'Chennai')));
              } else if (title == 'Today\'s') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => TodaysPage()));
              }
            },
            child: Text(seeall[globalLanguageOption] ?? 'See All'),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<NewsItem> newsItems) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          final newsItem = newsItems[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(left: 16),
            child: Card(
              elevation: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNewsImage(newsItem.imageUrl, 100.0),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      newsItem.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
    final categories = ['Politics', 'Sports', 'Entertainment', 'Business'];
    final categoriesImages = [
      'politics.png',
      'sports.png',
      'entertainment.png',
      'business.png',
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
                  Text(categories[index]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocations() {
    final locations = [
      'Chennai',
      'Cuddalore',
      'Thiruvannamalai',
      'Sivakasi',
      'Pondicherry',
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to LocationPage with the selected location
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      LocationPage(locationTag: locations[index]),
                ),
              );
            },
            child: Container(
              width: 100,
              child: Column(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 40,
                    color: const Color.fromARGB(255, 46, 78, 255),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    locations[index],
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
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
