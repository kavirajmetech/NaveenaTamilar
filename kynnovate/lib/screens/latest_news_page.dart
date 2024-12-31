import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'news_details_screen.dart';  // Assuming you have a detail screen

class LatestNewsPage extends StatefulWidget {
  @override
  _LatestNewsPageState createState() => _LatestNewsPageState();
}

class _LatestNewsPageState extends State<LatestNewsPage> {
  late Future<List<NewsItem>> latestItems;

  @override
  void initState() {
    super.initState();
    _loadLatestNews();
  }

  // Fetch latest news from the API or file
  Future<List<NewsItem>> _loadLatestNews() async {
    // Assuming the RSS URLs are stored in rssList.json
    final response = await http.get(Uri.parse('assets/rssList.json'));
    final data = json.decode(response.body);

    final urls = data['categories']['General'];
    return await fetchRssFeed(urls);
  }

  // Fetch RSS feed
  Future<List<NewsItem>> fetchRssFeed(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    for (String url in urls) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse the XML response here
        allNewsItems.addAll(parseRss(response.body));
      }
    }
    return allNewsItems;
  }

  // Parse RSS feed (add the logic for parsing)
  List<NewsItem> parseRss(String xmlContent) {
    // Your XML parsing logic here
    // Returning an empty list for simplicity
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Latest")),
      body: FutureBuilder<List<NewsItem>>(
        future: latestItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading news'));
          }
          final items = snapshot.data ?? [];
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(newsItem: items[index]),
                    ),
                  );
                },
                child: Card(
                  child: Column(
                    children: [
                      Image.network(items[index].imageUrl),
                      Text(items[index].title),
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
