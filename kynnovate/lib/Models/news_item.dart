import 'package:xml/xml.dart' as xml;

class NewsItem {
  final String title;
  final String link;
  final String description;
  final String imageUrl;

  NewsItem({
    required this.title,
    required this.link,
    required this.description,
    required this.imageUrl,
  });

  factory NewsItem.fromXml(xml.XmlElement element) {
    return NewsItem(
      title: element.findElements('title').single.text,
      link: element.findElements('link').single.text,
      description: element.findElements('description').single.text,
      imageUrl: element.findElements('media:thumbnail').isNotEmpty
          ? element.findElements('media:thumbnail').first.getAttribute('url') ?? ''
          : '',
    );
  }
}
