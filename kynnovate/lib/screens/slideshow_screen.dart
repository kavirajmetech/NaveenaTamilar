import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/news_item.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:kynnovate/landingpage.dart';

class SlideshowScreen extends StatefulWidget {
  @override
  _SlideshowScreenState createState() => _SlideshowScreenState();
}

class _SlideshowScreenState extends State<SlideshowScreen> {
  bool isSpeaking = false;
  List<int> likedArticles = [];
  List<NewsItem> articles = [];
  bool isLoading = true;
  final FlutterTts flutterTts = FlutterTts();
  int currentSlideIndex = 0;
  int articlesPerBatch = 10;
  int totalArticlesFetched = 0;
  int currentBatchStartIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchArticles();
    configureTts();
  }

  Future<void> configureTts() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);

    flutterTts.setCompletionHandler(() {
      setState(() {});
    });

    flutterTts.setCancelHandler(() {
      setState(() {});
    });
  }

  Future<void> fetchArticles() async {
    try {
      List<NewsItem> allNews = await fetchMultipleRssFeeds([
        "https://tamil.news18.com/commonfeeds/v1/tam/rss/chennai-district.xml",
        'https://www.dinakaran.com/feed/',
        'https://feeds.bbci.co.uk/news/world/rss.xml',
        'https://feeds.nbcnews.com/nbcnews/public/news',
        'https://tamil.oneindia.com/rss/feeds/tamil-technology-fb.xml'
      ]);

      totalArticlesFetched = allNews.length;
      List<NewsItem> fetchedArticles = fetchRandomNews(allNews);

      setState(() {
        articles = fetchedArticles;
        isLoading = false;
        currentBatchStartIndex = articles.length;
      });

      print("Initial articles fetched: ${articles.length}");
    } catch (e) {
      print("Error fetching initial articles: $e");
    }
  }

  Future<void> fetchMoreArticles() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<NewsItem> allNews = await fetchMultipleRssFeeds([
        "https://tamil.news18.com/commonfeeds/v1/tam/rss/chennai-district.xml",
        'https://www.dinakaran.com/feed/',
        'https://feeds.bbci.co.uk/news/world/rss.xml',
        'https://feeds.nbcnews.com/nbcnews/public/news',
        'https://tamil.oneindia.com/rss/feeds/tamil-technology-fb.xml'
      ]);

      totalArticlesFetched += allNews.length;
      List<NewsItem> fetchedArticles = fetchRandomNews(allNews);

      setState(() {
        articles.addAll(fetchedArticles);
        isLoading = false;
        currentBatchStartIndex = articles.length;
      });

      print("More articles fetched: ${fetchedArticles.length}");
    } catch (e) {
      print("Error fetching more articles: $e");
    }
  }

  Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
    List<NewsItem> allNewsItems = [];
    for (String url in urls) {
      final newsItems = await fetchRssFeedWithTimeout(url);
      allNewsItems.addAll(newsItems);
    }
    return allNewsItems;
  }

  Future<List<NewsItem>> fetchRssFeedWithTimeout(String url) async {
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(utf8.decode(response.bodyBytes));
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

  List<NewsItem> fetchRandomNews(List<NewsItem> allNews) {
    final random = Random();
    allNews.shuffle(random);
    return allNews.take(articlesPerBatch).toList();
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
    setState(() {
      isSpeaking = true;
    });
  }

  Future<void> stop() async {
    await flutterTts.stop();
    setState(() {
      isSpeaking = false;
    });
  }

  int currentTheme = 1;

  void toggleTheme(int controll) {
    if (controll == 1) {
      setState(() {
        currentTheme = (currentTheme == 1) ? 0 : 1;
      });
    } else {
      setState(() {
        currentTheme = currentTheme;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Shorts'),
        leading: IconButton(
          icon: Icon(Icons.home),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        toggleTheme: toggleTheme,
                      )),
            );
          },
        ),
      ),
      body: isLoading && articles.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: articles.length + (isLoading ? 1 : 0),
              onPageChanged: (index) {
                setState(() {
                  currentSlideIndex = index;
                });
                stop();
                if (index < articles.length) {
                  speak(articles[index].description);
                }

                if (index == currentBatchStartIndex - 5 &&
                    !isLoading &&
                    totalArticlesFetched < articles.length + articlesPerBatch) {
                  fetchMoreArticles();
                }
              },
              itemBuilder: (context, index) {
                if (index == articles.length && isLoading) {
                  return Center(child: CircularProgressIndicator());
                }
                final article = articles[index];
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: article.imageUrl.isNotEmpty &&
                              !article.imageUrl.startsWith('assets')
                          ? NetworkImage(article.imageUrl)
                          : AssetImage('assets/login.png') as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    color: Colors.black54.withOpacity(0.5),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 16.0,
                          right: 16.0,
                          child: IconButton(
                            icon: Icon(
                              isSpeaking && currentSlideIndex == index
                                  ? Icons.pause_circle_outline
                                  : Icons.play_circle_outline,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: () {
                              if (isSpeaking && currentSlideIndex == index) {
                                stop();
                              } else {
                                speak(article.description);
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 16.0,
                          right: 16.0,
                          child: IconButton(
                            icon: Icon(
                              Icons.thumb_up,
                              color: likedArticles.contains(index)
                                  ? Colors.blue
                                  : Colors.white,
                              size: 40,
                            ),
                            onPressed: () {
                              setState(() {
                                if (likedArticles.contains(index)) {
                                  likedArticles.remove(index);
                                } else {
                                  likedArticles.add(index);
                                }
                              });
                              print("Article liked!");
                            },
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                );
              },
            ),
    );
  }
}

