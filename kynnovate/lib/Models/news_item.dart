import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

class NewsItem {
  final String title;
  final String link;
  final String description;
  final String content;

  NewsItem({required this.title, required this.link, required this.description, required this.content});

  factory NewsItem.fromXml(xml.XmlElement element) {
    return NewsItem(
      title: element.findElements('title').single.text,
      link: element.findElements('link').single.text,
      description: element.findElements('description').single.text,
      content: element.findElements('content:encoded').single.text,
    );
  }
}

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
