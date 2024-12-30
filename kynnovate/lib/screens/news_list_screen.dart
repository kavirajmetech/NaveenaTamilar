// lib/screens/news_list_screen.dart
import 'package:flutter/material.dart';
import '../models/news_item.dart';
import '../services/rss_service.dart';

class NewsListScreen extends StatefulWidget {
  @override
  _NewsListScreenState createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  late Future<List<NewsItem>> futureNewsItems;

  @override
  void initState() {
    super.initState();
    futureNewsItems = RssService.fetchRssFeed('https://www.dinamani.com/api/v1/collections/cinema-news-cinema.rss');
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
