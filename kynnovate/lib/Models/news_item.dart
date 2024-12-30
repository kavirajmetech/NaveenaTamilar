import 'package:xml/xml.dart' as xml;

class NewsItem {
  final String title;
  final String link;
  final String description;

  NewsItem({required this.title, required this.link, required this.description});

  factory NewsItem.fromXml(xml.XmlElement element) {
    return NewsItem(
      title: element.findElements('title').single.text,
      link: element.findElements('link').single.text,
      description: element.findElements('description').single.text,
    );
  }
}
