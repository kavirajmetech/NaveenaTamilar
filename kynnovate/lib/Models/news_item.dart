import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as html_parser;

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
    String rawDescription = element.findElements('description').single.text;
    String parsedDescription = parseHtmlString(rawDescription);

    return NewsItem(
      title: element.findElements('title').single.text,
      link: element.findElements('link').single.text,
      description: parsedDescription,
      imageUrl: element.findElements('thumbimage').isNotEmpty
          ? element.findElements('thumbimage').first.text
          : element.findElements('media:thumbnail').isNotEmpty
          ? element.findElements('media:thumbnail').first.getAttribute('url') ?? ''
          : element.findElements('media:content').isNotEmpty
          ? element.findElements('media:content').first.getAttribute('url') ?? ''
          : element.findElements('image').isNotEmpty
          ? element.findElements('image').first.findElements('url').isNotEmpty
          ? element.findElements('image').first.findElements('url').single.text
          : ''
          : ''

    );
  }

  static String parseHtmlString(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body?.text ?? htmlString;
  }
}
