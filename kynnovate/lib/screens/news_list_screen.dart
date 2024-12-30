import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/news_item.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<NewsItem>> futureNewsItems;

  /// Fetch RSS feed from a single URL and parse it into a list of NewsItem
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

  /// Fetch multiple RSS feeds from a list of URLs
  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    for (String url in urls) {
      final newsItems = await fetchRssFeed(url);
      allNewsItems.addAll(newsItems);
    }
    return allNewsItems;
  }

  @override
  void initState() {
    super.initState();
    futureNewsItems = fetchMultipleRssFeeds([
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News List'),
      ),
      body: FutureBuilder<List<NewsItem>>(
        future: futureNewsItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load news: ${snapshot.error}'),
            );
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Center(child: Text('No news available.'));
          } else if (snapshot.hasData) {
            final newsItems = snapshot.data!;
            return ListView.builder(
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final newsItem = newsItems[index];
                return ListTile(
                  title: Text(newsItem.title),
                  subtitle: Text(newsItem.description),
                );
              },
            );
          } else {
            return Center(child: Text('Unknown error occurred.'));
          }
        },
      ),
    );
  }
}
