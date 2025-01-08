import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/landingpage.dart';
import 'package:xml/xml.dart' as xml;
import 'news_details_screen.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'news_list_screen.dart';

class ChannelPage extends StatefulWidget {
  final String channel;

  ChannelPage({required this.channel});

  @override
  _ChannelPageState createState() => _ChannelPageState();
}

class _ChannelPageState extends State<ChannelPage> {
  final channelList = {
    'Vikatan': [
      "https://www.vikatan.com/api/v1/collections/kollywood-entertainment.rss?&time-period=last-24-hours"
    ],
    'Hindu Tamil': ['https://feeds.feedburner.com/Hindu_Tamil_tamilnadu'],
    'BBC': ['https://feeds.bbci.co.uk/news/world/rss.xml'],
    'NBC': ['https://feeds.nbcnews.com/nbcnews/public/news'],
    'Dhinakaran': ['https://www.dinakaran.com/feed/'],
    'Times Of India': ['https://timesofindia.indiatimes.com/rss.cms']
  };

  late Future<List<NewsItem>> futureNewsItems;
  late Timer _timer;
  bool isLoading = true;
  String errorMessage = '';
  late ScrollController
      _scrollController; // Scroll controller for auto-scrolling

  Future<List<String>> fetchWords(String username) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('tempUser')
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

    return allNewsItems;
  }

  // Refresh method to reload data
  Future<void> _refreshNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      futureNewsItems = fetchMultipleRssFeeds(
          channelList[widget.channel] == null
              ? ['https://www.dinakaran.com/feed/']
              : channelList[widget.channel]!);
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
                          'Channels',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  _buildChannels(),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Text(
                      widget.channel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
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
          return _buildSectionError(widget.channel);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptySection(widget.channel);
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
            'Upgrade Pro to Continue',
            style: const TextStyle(color: Colors.red),
          ),
          TextButton(
            onPressed: _refreshNews,
            child: const Text(''),
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

  Widget _buildChannels() {
    final channels = [
      'Dhinakaran',
      'Hindu Tamil',
      'BBC',
      'NBC',
      'Vikatan',
      'Times Of India'
    ];
    final channelsImages = [
      'Dhinakaran.png',
      'Hindu.png',
      'BBC.png',
      'NBC.jpg',
      'TOI.png',
      'Vikatan.png',
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: channels.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navigate to ChannelPage with the selected channel
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChannelPage(channel: channels[index]),
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
                        AssetImage('assets/images/${channelsImages[index]}'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    channels[index],
                    style: TextStyle(
                      fontWeight: widget.channel == channels[index]
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
