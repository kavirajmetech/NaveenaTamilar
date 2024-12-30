import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_item.dart';
import '../services/rss_service.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final RssService _rssService = RssService();
  late Future<List<NewsItem>> futureNewsItems;

<<<<<<< HEAD
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
    for (String url in urls) {
      final newsItems = await fetchRssFeed(url);
      allNewsItems.addAll(newsItems);
    }
    return allNewsItems;
  }

=======
>>>>>>> c3a4afec79065a861a633dacb7f4c39c654976f6
  @override
  void initState() {
    super.initState();
    futureNewsItems = loadRssFeeds();
  }

  Future<List<NewsItem>> loadRssFeeds() async {
    final jsonString = await rootBundle.rootBundle.loadString('lib/RSS_Data/rssList.json');
    final jsonResponse = json.decode(jsonString);
    List<String> rssUrls = extractUrlsFromJson(jsonResponse);
    return _rssService.fetchMultipleRssFeeds(rssUrls);
  }

  List<String> extractUrlsFromJson(Map<String, dynamic> jsonResponse) {
    List<String> urls = [];

    void extractUrls(dynamic value) {
      if (value is List) {
        urls.addAll(value.cast<String>());
      } else if (value is Map) {
        value.values.forEach(extractUrls);
      }
    }

    jsonResponse.values.forEach(extractUrls);
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News List'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: futureNewsItems,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final newsItems = snapshot.data!;
            return ListView.builder(
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final newsItem = newsItems[index];
                return Card(
                  margin: EdgeInsets.all(10.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 5.0,
                  child: InkWell(
                    onTap: () {
                      // Handle tap
                    },
                    child: Column(
                      children: [
                        newsItem.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: newsItem.imageUrl,
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                            : Container(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                newsItem.title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                newsItem.description,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
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
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
