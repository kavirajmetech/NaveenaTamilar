// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:kynnovate/Models/news_item.dart';
// import 'news_details_screen.dart';  // Assuming you have a detail screen

// class LocationPage extends StatelessWidget {
//   final String locationTag;

//   LocationPage({required this.locationTag});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Location: $locationTag'),
//       ),
//       body: Center(
//         child: Text('News for $locationTag'),
//       ),
//     );
//   }
// }

// // class _LocationPageState extends State<LocationPage> {
// //   String selectedLocation = "Chennai"; // Default location
// //   late Future<List<NewsItem>> locationNewsItems;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadLocationNews(selectedLocation);
// //   }

// //   // Load news based on location
// //   Future<void> _loadLocationNews(String location) async {
// //     final response = await http.get(Uri.parse('assets/rssList.json'));
// //     final data = json.decode(response.body);
// //     final locationUrls = data['categories']['Regional'][location];
// //     locationNewsItems = fetchRssFeed(locationUrls);
// //     setState(() {});
// //   }

// //     List<NewsItem> parseRss(String xmlContent) {
// //     // Your XML parsing logic here
// //     // Returning an empty list for simplicity
// //     return [];
// //   }

// //   // Fetch RSS feed
// //   Future<List<NewsItem>> fetchRssFeed(List<String> urls) async {
// //     List<NewsItem> allNewsItems = [];
// //     for (String url in urls) {
// //       final response = await http.get(Uri.parse(url));
// //       if (response.statusCode == 200) {
// //         // Parse the XML response here
// //         allNewsItems.addAll(parseRss(response.body));
// //       }
// //     }
// //     return allNewsItems;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Location: $selectedLocation')),
// //       body: Column(
// //         children: [
// //           // Dropdown to select location
// //           DropdownButton<String>(
// //             value: selectedLocation,
// //             onChanged: (String? newValue) {
// //               if (newValue != null) {
// //                 setState(() {
// //                   selectedLocation = newValue;
// //                 });
// //                 _loadLocationNews(newValue);
// //               }
// //             },
// //             items: <String>[
// //               'Chennai', 'Cuddalore', 'Thiruvannamalai', 'Sivakasi', 'Pondicherry'
// //             ].map<DropdownMenuItem<String>>((String value) {
// //               return DropdownMenuItem<String>(
// //                 value: value,
// //                 child: Text(value),
// //               );
// //             }).toList(),
// //           ),
// //           // News list based on location
// //           Expanded(
// //             child: FutureBuilder<List<NewsItem>>(
// //               future: locationNewsItems,
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return Center(child: CircularProgressIndicator());
// //                 }
// //                 if (snapshot.hasError) {
// //                   return Center(child: Text('Error loading news'));
// //                 }
// //                 final items = snapshot.data ?? [];
// //                 return ListView.builder(
// //                   itemCount: items.length,
// //                   itemBuilder: (context, index) {
// //                     return GestureDetector(
// //                       onTap: () {
// //                         Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) => NewsDetailScreen(newsItem: items[index]),
// //                           ),
// //                         );
// //                       },
// //                       child: Card(
// //                         child: Column(
// //                           children: [
// //                             Image.network(items[index].imageUrl),
// //                             Text(items[index].title),
// //                           ],
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:xml/xml.dart' as xml;
import '../landingpage.dart';
import 'category_page.dart';
import 'latest_news_page.dart';
import 'location_page.dart';
import 'news_details_screen.dart';
// import 'news_item.dart';
import 'dart:async';


import 'todays_page.dart';

class LocationPage extends StatefulWidget {
  final String locationTag;

  // Constructor for LocationPage
  LocationPage({required this.locationTag});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final locationList = {
    "Chengalpattu": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/chengalpattu-district.xml"
    ],
    "Chennai": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/chennai-district.xml"
    ],
    "Coimbatore": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/coimbatore-district.xml"
    ],
    "Cuddalore": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/cuddalore-district.xml"
    ],
    "Dharmapuri": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/dharmapuri-district.xml"
    ],
    "Dindigul": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/dindigul-district.xml"
    ],
    "Erode": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/erode-district.xml"
    ],
    "Kallakurichi": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/kallakurichi-district.xml"
    ],
    "Kanniyakumari": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/kanniyakumari-district.xml"
    ],
    "திருவண்ணாமலை": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/tiruvannamalai.xml"
    ],
    "மதுரை": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/madurai.xml"
    ],
    "Karur District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/karur-district.xml"
    ],
    "krishnagiri District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/krishnagiri-district.xml"
    ],
    "live tv": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/live-tv.xml"
    ],
    "Madurai District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/madurai-district.xml"
    ],
    "Mayiladuthurai District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/mayiladuthurai-district.xml"
    ],
    "michaung cyclone": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/michaung-cyclone.xml"
    ],
    "Nagapattinam District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/nagapattinam-district.xml"
    ],
    "Namakkal District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/namakkal-district.xml"
    ],
    "Nilgiris District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/nilgiris-district.xml"
    ],
    "Perambalur District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/perambalur-district.xml"
    ],
    "Pudukkottai District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/pudukkottai-district.xml"
    ],
    "Ramanathapuram District": [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/ramanathapuram-district.xml"
    ]
  };
  late Future<List<NewsItem>> futureNewsItems;
  bool isLoading = true;
  String errorMessage = '';
  int _currentPage = 1; // Track the current page
  bool _isFetchingMore = false; // Prevent multiple fetches
  List<NewsItem> _newsItems = []; // Scroll controller for auto-scrolling
  late ScrollController
  _scrollController;
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
        locationList[widget.locationTag] ?? ['https://www.dinakaran.com/feed/'],
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
        locationList[widget.locationTag] ?? ['https://www.dinakaran.com/feed/'],
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
                    'Locations',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            ),
            // _buildSectionHeader('Categories'),
            _buildLocations(),
            _buildSectionHeader(widget.locationTag),
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
          return _buildSectionError(widget.locationTag);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection(widget.locationTag);
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
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget _buildHorizontalList(List<NewsItem> newsItems) {
  //   return SizedBox(
  //     height: 150,
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: newsItems.length,
  //       itemBuilder: (context, index) {
  //         final newsItem = newsItems[index];
  //         return Container(
  //           width: 200,
  //           margin: const EdgeInsets.only(left: 16),
  //           child: Card(
  //             elevation: 5,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 _buildNewsImage(newsItem.imageUrl, 100.0),
  //                 Padding(
  //                   padding: const EdgeInsets.all(8.0),
  //                   child: Text(
  //                     newsItem.title,
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

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

  Widget _buildLocations() {
    final locations = [
      'Chennai',
      'Cuddalore',
      'திருவண்ணாமலை',
      'மதுரை',
      'Coimbatore',
      'Chengalpattu',
      'Dharmapuri',
      'Dindigul',
      'Erode',
      'Kallakurichi',
      'Kanniyakumari',

    ];
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to LocationPage with the selected category
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
                  const Icon(
                    Icons.location_on,
                    size: 40,
                    color: Color.fromARGB(255, 46, 78, 255),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 8),
                  Text(
                    locations[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: widget.locationTag == locations[index]
                          ? FontWeight.w600
                          : FontWeight.w400,
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
