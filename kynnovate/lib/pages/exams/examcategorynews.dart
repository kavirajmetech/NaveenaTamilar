import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/config.dart';
import 'package:kynnovate/globals.dart';
import 'package:kynnovate/landingpage.dart';
import 'package:kynnovate/screens/news_details_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:kynnovate/Models/news_item.dart';

class Examcategorynews extends StatefulWidget {
  final String category;
  final String fullcategory;
  Examcategorynews({required this.category, required this.fullcategory});
  @override
  _ExamCategorynews createState() => _ExamCategorynews();
}

class _ExamCategorynews extends State<Examcategorynews> {
  late List<NewsItem> newsItems = [];
  final FlutterTts _flutterTts = FlutterTts();
  String? generatedQuestion;
  final translator = GoogleTranslator();
  // late final String thiscategory;
  // late final String thisfullcategory;

  @override
  void initState() {
    super.initState();
    _loadNewsItems();
    // setState(() {
    //   thiscategory = widget.category;
    //   thisfullcategory = widget.fullcategory;
    // });
  }

  Future<void> _loadNewsItems() async {
    try {
      final urls = {
        "Politics": [
          "https://www.news18.com/commonfeeds/v1/eng/rss/politics.xml"
        ],
        "Education": [
          "https://timesofindia.indiatimes.com/rssfeeds/913168846.cms"
        ],
        "Examination": [
          "https://upsctree.com/feed/",
          "https://officersiasacademy.com/feed/",
          "https://iascoachings.com/feed/"
        ],
        "Technology": [
          "https://tamil.oneindia.com/rss/feeds/tamil-technology-fb.xml",
          "https://www.news18.com/commonfeeds/v1/eng/rss/tech.xml"
        ],
        "Economics": [
          "https://rss.nytimes.com/services/xml/rss/nyt/Economy.xml",
          "https://rss.nytimes.com/services/xml/rss/nyt/Business.xml",
          "https://www.vikatan.com/stories.rss?section=business&time-period=last-24-hours",
          "https://www.indiatoday.in/rss/1206513",
          "https://marginalrevolution.com/feed",
          "https://econbrowser.com/feed"
        ],
      };

      final fetchedNews = await fetchMultipleRssFeeds(urls[widget.category]!);
      setState(() {
        newsItems = fetchedNews;
      });
    } catch (e) {
      print('Error loading news items: $e');
    }
  }

  Future<List<NewsItem>> fetchRssFeed(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final deco = utf8.decode(response.bodyBytes);
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(deco);
        final items = document.findAllElements('item');
        return items.map((element) => NewsItem.fromXml(element)).toList();
      }
    } catch (e) {
      print('Error fetching RSS feed from $url: $e');
    }
    return [];
  }

  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    for (String url in urls) {
      final newsItems = await fetchRssFeed(url);
      allNewsItems.addAll(newsItems);
    }
    return allNewsItems;
  }

  void _readAloud(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          widget.fullcategory,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: newsItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final news = newsItems[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Stack(
                    children: [
                      //background image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          news.imageUrl!,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          opacity: AlwaysStoppedAnimation(1.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withOpacity(0.8),
                              Colors.transparent
                            ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                        height: 220,
                      ),
                      SizedBox(height: 10),
                      // Content
                      Positioned(
                        bottom: 10,
                        left: 10,
                        right: 10,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder<String>(
                              future: translator
                                  .translate(news.title!, from: 'en', to: 'ta')
                                  .then((value) => value.toString()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading translation...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return const Text(
                                    "Error translating...",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }
                                return Text(
                                  snapshot.data ?? "",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            FutureBuilder<String>(
                              future: translator
                                  .translate(news.description!,
                                      from: 'en', to: 'ta')
                                  .then((value) => value.toString()),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    "Loading translation...",
                                    style: TextStyle(color: Colors.white),
                                  );
                                }
                                if (snapshot.hasError) {
                                  return const Text(
                                    "Error translating...",
                                    style: TextStyle(color: Colors.red),
                                  );
                                }
                                return Text(
                                  snapshot.data ?? "",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final response = await fetchQuestionFromAI(
                                        "Generate one question from this content: ${news.description}");
                                    showdropdownpopup(response);
                                  },
                                  icon: const Icon(Icons.question_answer),
                                  label: const Text("Question"),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _readAloud(
                                    "${news.title}. ${news.description}",
                                  ),
                                  icon: const Icon(Icons.volume_up),
                                  label: const Text("Read Aloud"),
                                ),
                              ],
                            ),
                            // ElevatedButton(
                            //   onPressed: () {
                            //     Navigator.push(
                            //       context,
                            //       MaterialPageRoute(
                            //         builder: (context) =>
                            //             NewsDetailScreen(newsItem: news),
                            //       ),
                            //     );
                            //   },
                            //   child: const Text("Look"),
                            // ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                        bottomRight: Radius.zero,
                                      ),
                                    ),
                                    side: BorderSide(
                                      color: Colors.white, // Border color
                                      width: 0.6, // Border width
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    backgroundColor: WidgetStateColor
                                        .transparent // Customize the button color
                                    ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NewsDetailScreen(newsItem: news),
                                    ),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Look",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            )
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

  void showdropdownpopup(String response) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            "Possible question from this byte....",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(response),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Close",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
