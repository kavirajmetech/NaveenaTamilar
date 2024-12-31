import 'dart:convert'; // Ensure proper encoding
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart'; // To load asset files

class SlideshowScreen extends StatefulWidget {
  @override
  _SlideshowScreenState createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen> {
  List<NewsItem> articles = [];
  bool isLoading = true;
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    print("Fetching articles...");
    List<NewsItem> allNews = await fetchMultipleRssFeeds([
      'https://www.dinakaran.com/feed/',
      'https://timesofindia.indiatimes.com/rssfeedstopstories.cms',
      'https://www.thanthitv.com/feed',
      'https://timesofindia.indiatimes.com/rssfeeds/1221656.cms',
      'https://www.indiatoday.in/rss/home',
      'https://feeds.bbci.co.uk/news/world/rss.xml',
      'https://beta.dinamani.com/api/v1/collections/latest-news.rss',
      'https://feeds.nbcnews.com/nbcnews/public/news',
      'https://tamil.oneindia.com/rss/feeds/tamil-technology-fb.xml',
      'https://tamil.oneindia.com/rss/feeds/tamil-weather-fb.xml',
      'https://tamil.oneindia.com/rss/feeds/tamil-news-fb.xml',
      'https://tamil.news18.com/commonfeeds/v1/tam/rss/sports/cricket.xml',
      'https://tamil.news18.com/commonfeeds/v1/tam/rss/virudhunagar-district.xml',
      'https://tamil.news18.com/commonfeeds/v1/tam/rss/chennai-district.xml',
    ]);


    List<NewsItem> fetchedArticles = fetchRandomNews(allNews);

    for (var article in fetchedArticles) {
      // Check if image URL is provided, otherwise use login.png
      String imageUrl = article.imageUrl.isNotEmpty ? article.imageUrl : 'assets/login.png';

      article = NewsItem(
        title: utf8.decode(article.title.codeUnits), // Ensure UTF-8 encoding
        link: article.link,
        description: utf8.decode(article.description.codeUnits), // Ensure UTF-8 encoding
        imageUrl: imageUrl,
      );
    }

    setState(() {
      articles = fetchedArticles;
      isLoading = false;
    });
    print("Articles fetched successfully.");
  }

  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    for (String url in urls) {
      print("Fetching RSS feed from $url");
      final newsItems = await fetchRssFeedWithTimeout(url);
      allNewsItems.addAll(newsItems);
      print("Fetched ${newsItems.length} items from $url");
    }
    return allNewsItems;
  }

  Future<List<NewsItem>> fetchRssFeedWithTimeout(String url) async {
    try {
      print('Starting request for $url');
      final response = await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      print('Response received for $url with status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        try {
          final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
          final items = document.findAllElements('item');
          print('Parsed ${items.length} items from $url');
          return items.map((element) => NewsItem.fromXml(element)).toList();
        } catch (e) {
          print('Error parsing XML from $url: $e');
          return [];
        }
      } else {
        print('Failed to load RSS feed from $url (Status Code: ${response.statusCode})');
        return [];
      }
    } catch (e) {
      print('Error fetching RSS feed from $url: $e');
      return [];
    }
  }

  List<NewsItem> fetchRandomNews(List<NewsItem> allNews) {
    final random = Random();
    allNews.shuffle(random);
    return allNews.take(5).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News Shorts')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
        scrollDirection: Axis.vertical, // Change to vertical scroll
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: article.imageUrl.startsWith('assets')
                    ? AssetImage(article.imageUrl)
                    : NetworkImage(article.imageUrl) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.black54,
                  child: Column(
                    children: [
                      Text(
                        article.title,
                        style: TextStyle(
                          fontFamily: 'TamilFont',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        article.description,
                        style: TextStyle(
                          fontFamily: 'TamilFont',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
