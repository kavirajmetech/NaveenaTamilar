import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:kynnovate/Models/news_item.dart';
import 'package:translator/translator.dart';
import 'package:xml/xml.dart' as xml;
import 'package:http/http.dart' as http;

String? globalUserId;
String? globalUsername;
String? globalEmail;
int? globaltheme = 1;

// stt.SpeechToText _speech = stt.SpeechToText();

Map<String, dynamic> globalOptions = {};
Map<String, dynamic> globalUserData = {};
bool globalloadedvariables = false;
bool globalloadedpreferences = false;
bool globalloadednewsitem = false;
String globalLanguageOption = 'en';
late Future<List<NewsItem>> globalfutureNewsItems;
final FlutterTts globalflutterTts = FlutterTts();
final gobaltranslator = GoogleTranslator();

class ThemeNotifier extends ChangeNotifier {
  int _theme = 1;

  int get theme => _theme;

  void changeTheme(int newTheme) {
    if (_theme != newTheme) {
      _theme = newTheme;
      notifyListeners();
    }
  }
}

ThemeNotifier themeNotifier = ThemeNotifier();

Future<void> fetchUserDetails() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();

      if (userDoc.exists) {
        globalUserData = userDoc.data() as Map<String, dynamic>;
        globalloadedvariables = true;
      } else {
        print("No user data found in Firestore.");
      }
    } else {
      print("No user signed in.");
    }
  } catch (e) {
    print("Error fetching user details: $e");
  }
}

Future<List<NewsItem>> globalfetchRssFeed(String url) async {
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

Future<List<NewsItem>> gloabalfetchMultipleRssFeeds(List<String> urls) async {
  List<NewsItem> allNewsItems = [];
  List<String> failedUrls = [];

  for (String url in urls) {
    try {
      final newsItems = await globalfetchRssFeed(url);
      if (newsItems.isNotEmpty) {
        allNewsItems.addAll(newsItems.take(5));
      } else {
        failedUrls.add(url);
      }
    } catch (e) {
      failedUrls.add(url);
      print('Error fetching from $url: $e');
    }
  }

  if (allNewsItems.isEmpty && failedUrls.isNotEmpty) {
    throw Exception('Failed to fetch news from any source');
  }

  return allNewsItems;
}

Future<void> globalrefreshNews() async {
  try {
    globalfutureNewsItems = gloabalfetchMultipleRssFeeds([
      "https://www.dinakaran.com/feed/",
      "https://kidsactivitiesblog.com/category/kids-activities/feed/",
      'https://feeds.feedburner.com/Hindu_Tamil_tamilnadu',
      'https://feeds.bbci.co.uk/news/world/rss.xml',
      'https://feeds.nbcnews.com/nbcnews/public/news',
      'https://www.dinakaran.com/feed/',
      'https://timesofindia.indiatimes.com/rss.cms',
      'https://feeds.bbci.co.uk/news/world/rss.xml'
    ]);
  } catch (e) {
    print(e);
  }
}

Future<String> fetchQuestionFromAI(String query) async {
  print("Reached Gen AI");
  final apiKey = 'AIzaSyBHbQhbhN55b1RR00vbUfgeoVoAZgAuj6s';
  final url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'contents': [
          {
            'parts': [
              {
                'text': query,
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['candidates'] != null &&
          responseData['candidates'] is List &&
          responseData['candidates'].isNotEmpty) {
        final textContent =
            responseData['candidates'][0]['content']['parts'][0]['text'];
        print(textContent.toString());
        return textContent.toString();
      } else {
        print("Invalid response structure: $responseData");
        return "No valid candidates found.";
      }
    } else {
      print("Request failed with status: ${response.statusCode}");
      return "Upgrade to pro to use this feature!!!";
    }
  } catch (e) {
    print("Error fetching question: $e");
    return "Upgrade to pro to use this feature!!!";
  }
}
