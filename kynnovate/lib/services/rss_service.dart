import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../models/news_item.dart';

class RssService {
  Future<List<NewsItem>> fetchRssFeed(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final document = xml.XmlDocument.parse(response.body);
      final items = document.findAllElements('item');
      return items.map((element) => NewsItem.fromXml(element)).toList();
    } else {
      throw Exception('Failed to load RSS feed');
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
}
