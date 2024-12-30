import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../services/rss_service.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final RssService _rssService = RssService();
  late Future<List<NewsItem>> futureNewsItems;

  @override
  void initState() {
    super.initState();
    futureNewsItems = _rssService.fetchMultipleRssFeeds([
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
          if (snapshot.hasData) {
            final newsItems = snapshot.data!;
            return ListView.builder(
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final newsItem = newsItems[index];
                return ListTile(
                  title: Text(newsItem.title),
                  subtitle: Text(newsItem.description),
                  onTap: () {
                    // Handle tap
                  },
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
