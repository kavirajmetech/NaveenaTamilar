// lib/services/rss_service.dart
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/news_item.dart';

class RssService {
  static Future<List<NewsItem>> fetchRssFeed(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');
      return items.map((element) => NewsItem.fromXml(element)).toList();
    } else {
      throw Exception('Failed to load RSS feed');
    }
  }
}
