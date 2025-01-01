import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:xml/xml.dart';
import 'news_details_screen.dart';

class LatestNewsPage extends StatefulWidget {
  @override
  _LatestNewsPageState createState() => _LatestNewsPageState();
}

class _LatestNewsPageState extends State<LatestNewsPage> {
  late Future<List<NewsItem>> latestItems;

  @override
  void initState() {
    super.initState();
    latestItems = _loadLatestNews();
  }

  Future<List<NewsItem>> _loadLatestNews() async {
    final String url = "https://www.dinakaran.com/feed/"; // RSS URL
    return await fetchRssFeed(url);
  }

  Future<List<NewsItem>> fetchRssFeed(String url) async {
    List<NewsItem> allNewsItems = [];
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        allNewsItems.addAll(parseRss(response.body));
      }
    } catch (e) {
      print('Error fetching RSS feed from $url: $e');
    }
    return allNewsItems;
  }

  List<NewsItem> parseRss(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);
    final items = document.findAllElements('item');
    List<NewsItem> newsItems = [];

    for (final element in items) {
      newsItems.add(NewsItem.fromXml(element));
    }

    return newsItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Latest News"),
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: latestItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading news: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'No news available',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final newsItem = items[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          NewsDetailScreen(newsItem: newsItem),
                    ),
                  );
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display news image
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10)),
                        child: Image.network(
                          newsItem.imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 200,
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 50),
                              ),
                            );
                          },
                        ),
                      ),
                      // News title and description
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              newsItem.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              newsItem.description,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
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
