import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/globals.dart';
import 'package:kynnovate/landingpage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:translator/translator.dart';
import 'package:xml/xml.dart' as xml;

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:kynnovate/Models/news_item.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:kynnovate/Models/news_item.dart';

class KidsNewsPage extends StatefulWidget {
  @override
  _KidsNewsPageState createState() => _KidsNewsPageState();
}

class _KidsNewsPageState extends State<KidsNewsPage> {
  late List<Map<String, String>> newsItems = [];
  final FlutterTts _flutterTts = FlutterTts();
  final translator = GoogleTranslator();
  final List<String> images = [
    'assets/ben10.png',
    'assets/bheem.png',
    'assets/chinchan.png',
    'assets/cartoon.png',
    'assets/ben10.png',
    'assets/bheem.png',
    'assets/chinchan.png',
    'assets/cartoon.png',
  ];

  @override
  void initState() {
    print('languages' + globalLanguageOption);
    super.initState();
    _loadNewsItems();
  }

  Future<void> _loadNewsItems() async {
    try {
      final urls = [
        // "https://beta.dinamani.com/api/v1/collections/siruvarmani-weekly-supplements.rss",
        "https://kidsactivitiesblog.com/category/kids-activities/feed/",
        // "https://www.superhealthykids.com/feed/",
        // "https://handsonaswegrow.com/feed/",
        // "https://www.activityvillage.co.uk/rss.xml",
        // "https://supersimple.com/feed/",
        // "https://beta.dinamani.com/api/v1/collections/children-health-health.rss",
      ];

      final fetchedNews = await fetchMultipleRssFeeds(urls);
      setState(() {
        newsItems = fetchedNews
            .map((item) => {
                  "title": item.title,
                  "content": item.description,
                })
            .toList();
      });
      print(newsItems);
      print('loaded everything');
    } catch (e) {
      print('Error loading news items: $e');
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

  void _readAloud(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: newsItems.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: newsItems.length,
              itemBuilder: (context, index) {
                final news = newsItems[index];
                final randomImage = images[Random().nextInt(images.length)];

                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: SizedBox(
                    height: 280,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            randomImage,
                            height: 280, // Image height matches card height
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FutureBuilder<String>(
                                  future: translator
                                      .translate(news["title"]!,
                                          to: globalLanguageOption)
                                      .then((value) => value.toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "Loading translation...",
                                        style: TextStyle(color: Colors.white),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Text(
                                        "Error translating...",
                                        style: TextStyle(color: Colors.white),
                                      );
                                    }
                                    return SingleChildScrollView(
                                      child: Text(
                                        snapshot.data ?? "",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                              Container(
                                height: 150,
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: FutureBuilder<String>(
                                  future: translator
                                      .translate(news["content"]!,
                                          to: globalLanguageOption)
                                      .then((value) => value.toString()),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Text(
                                        "Loading translation...",
                                        style: TextStyle(color: Colors.white),
                                      );
                                    }
                                    if (snapshot.hasError) {
                                      return Text(
                                        "Error translating...",
                                        style: TextStyle(color: Colors.white),
                                      );
                                    }
                                    return SingleChildScrollView(
                                      child: Text(
                                        snapshot.data ?? "",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 5),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () => _readAloud(
                                    "${news["title"]}. ${news["content"]}",
                                  ),
                                  icon: Icon(Icons.volume_up),
                                  label: Text("Read Aloud"),
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
            ),
    );
  }
}
