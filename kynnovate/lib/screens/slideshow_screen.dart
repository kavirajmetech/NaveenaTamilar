// lib/screens/slideshow_screen.dart

import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/news_item.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:path_provider/path_provider.dart';

class SlideshowScreen extends StatefulWidget {
  @override
  _SlideshowScreenState createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen> {
  List<NewsItem> articles = [];
  bool isLoading = true;
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    List<NewsItem> allNews = await fetchMultipleRssFeeds([
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

    List<NewsItem> fetchedArticles = fetchRandomNews(allNews);

    for (var article in fetchedArticles) {
      // Check if image URL is provided, otherwise use login.png
      String imageUrl = article.imageUrl.isNotEmpty ? article.imageUrl : 'assets/login.png';

      // Generate TTS audio file
      await narrateArticle(article.description);

      article = NewsItem(
        title: article.title,
        link: article.link,
        description: article.description,
        imageUrl: imageUrl,
      );
    }

    setState(() {
      articles = fetchedArticles;
      isLoading = false;
    });
  }

  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    for (String url in urls) {
      final newsItems = await fetchRssFeed(url);
      allNewsItems.addAll(newsItems);
    }
    return allNewsItems;
  }

  Future<List<NewsItem>> fetchRssFeed(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        return items.map((element) => NewsItem.fromXml(element)).toList();
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

  Future<void> narrateArticle(String text) async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);

    // Get the directory to save the audio file
    final directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/${text.hashCode}.mp3';
    await flutterTts.synthesizeToFile(text, path);
  }

  Future<void> playAudio(String text) async {
    final directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/${text.hashCode}.mp3';
    if (File(path).existsSync()) {
      await audioPlayer.play("assets/audio/sample.mp3");
    } else {
      print("Audio file not found: $path");
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('News Slideshow')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
        itemCount: articles.length,
        onPageChanged: (index) {
          audioPlayer.stop(); // Stop any currently playing audio when the page changes
        },
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
                      Text(article.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 10),
                      Text(article.description, style: TextStyle(color: Colors.white)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () => playAudio(article.description),
                        child: Text('Listen'),
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
