import 'dart:math';

import 'package:xml/xml.dart' as xml;
import 'package:html/parser.dart' as html_parser;

class NewsItem {
  final String title;
  final String link;
  final String description;
  final String imageUrl;
  final String author;
  final String sourceName;
  final String category;
  final String date;

  NewsItem({
    required this.title,
    required this.link,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.sourceName,
    required this.category,
    required this.date,
  });

  factory NewsItem.fromXml(xml.XmlElement element) {
    String getElementText(String tag, {String defaultValue = ''}) {
      final foundElements = element.findElements(tag);
      return foundElements.isNotEmpty ? foundElements.first.text : defaultValue;
    }

    String getElementAttribute(String tag, String attribute,
        {String defaultValue = ''}) {
      final foundElements = element.findElements(tag);
      return foundElements.isNotEmpty
          ? foundElements.first.getAttribute(attribute) ?? defaultValue
          : defaultValue;
    }

    String rawDescription = getElementText('description');
    String parsedDescription = parseHtmlString(rawDescription);
    String imageUrl = element.findElements('thumbimage').isNotEmpty
        ? element.findElements('thumbimage').first.text
        : element.findElements('description').isNotEmpty
            ? element.findElements('a').first.getAttribute('src') ?? ''
            : element.findElements('media:thumbnail').isNotEmpty
                ? element
                        .findElements('media:thumbnail')
                        .first
                        .getAttribute('url') ??
                    ''
                : element.findElements('content:encoded').isNotEmpty
                    ? RegExp(r'<img src="([^"]+)"')
                            .firstMatch(element
                                .findElements('content:encoded')
                                .first
                                .text)
                            ?.group(1) ??
                        ''
                    : element.findElements('media:content').isNotEmpty
                        ? element
                                .findElements('img')
                                .first
                                .getAttribute('src') ??
                            ''
                        : element.findElements('image').isNotEmpty
                            ? element
                                    .findElements('image')
                                    .first
                                    .findElements('url')
                                    .isNotEmpty
                                ? element
                                    .findElements('image')
                                    .first
                                    .findElements('url')
                                    .single
                                    .text
                                : ''
                            : '';

    return NewsItem(
      title: getElementText('title'),
      link: getElementText('link'),
      description: parsedDescription,
      imageUrl: imageUrl.isNotEmpty
          ? imageUrl
          : 'https://miro.medium.com/v2/resize:fit:20864/1*oM1GuZ0oC3_9v1GfKC2Egg.jpeg',
      author: getElementText('author', defaultValue: 'Unknown Author'),
      sourceName: getElementText('source', defaultValue: 'Open Source'),
      category: getElementText('category', defaultValue: 'General Category'),
      date: getElementText('pubDate', defaultValue: 'Recent News'),
    );
  }
  static String parseHtmlString(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body?.text ?? htmlString;
  }
}
