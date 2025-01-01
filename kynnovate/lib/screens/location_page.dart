import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:xml/xml.dart' as xml;
import 'category_page.dart';
import 'latest_news_page.dart';
import 'location_page.dart';
import 'news_details_screen.dart';
import 'dart:async';

import 'todays_page.dart';

class LocationPage extends StatefulWidget {
  final String locationTag;

  LocationPage({required this.locationTag});

  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final locationList = {
    'Politics': [
      "https://www.vikatan.com/stories.rss?section-id=8962&time-period=last-24-hours"
    ],
    'Sports': [
      "https://tamil.news18.com/commonfeeds/v1/tam/rss/sports/cricket.xml"
    ],
    'Entertainment': [
      "https://www.vikatan.com/stories.rss?section-id=8956&time-period=last-24-hours",
      "https://www.vikatan.com/api/v1/collections/kollywood-entertainment.rss?&time-period=last-24-hours"
    ],
    'Business': [
      "https://www.vikatan.com/stories.rss?section=business&time-period=last-24-hours"
    ]
  };
  late Future<List<NewsItem>> futureNewsItems;
  late Timer _timer;
  bool isLoading = true;
  String errorMessage = '';
  late ScrollController _scrollController;

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

  Future<void> _refreshNews() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      futureNewsItems = fetchMultipleRssFeeds(
          locationList[widget.locationTag] == null
              ? ['https://www.dinakaran.com/feed/']
              : locationList[widget.locationTag]!);
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

    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double currentScroll = _scrollController.position.pixels;

        if (currentScroll == maxScroll) {
          _scrollController.jumpTo(0);
        } else {
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
                  _buildSectionHeader('Locations'),
                  _buildLocations(),
                  _buildSectionHeader(widget.locationTag),
                  _buildAllNews(),
                ],
              ),
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

  Widget _buildNewsItem(NewsItem item) {
    double boxWidth = 350;

    return GestureDetector(
      onTap: () {
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
            Image.network(
              item.imageUrl,
              width: boxWidth,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  height: 250,
                  width: boxWidth,
                  child: const Icon(Icons.image_not_supported),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  height: 250,
                  width: boxWidth,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.0),
                width: boxWidth,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.grey.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Text(
                  item.title.length > 50
                      ? "${item.title.substring(0, 50)}..."
                      : item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 2,
                  softWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
