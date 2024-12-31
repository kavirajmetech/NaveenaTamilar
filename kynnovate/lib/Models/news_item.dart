// import 'package:xml/xml.dart' as xml;
// import 'package:html/parser.dart' as html_parser;

// class NewsItem {
//   final String title;
//   final String link;
//   final String description;
//   final String imageUrl;
//   final String author;
//   final String source_name;
//   final String category;

//   NewsItem({
//     required this.title,
//     required this.link,
//     required this.description,
//     required this.imageUrl,
//     required this.author,
//     required this.source_name,
//     required this.category,
//   });

//   factory NewsItem.fromXml(xml.XmlElement element) {
//     String rawDescription = element.findElements('description').single.text;
//     String parsedDescription = parseHtmlString(rawDescription);

//     return NewsItem(
//         title: element.findElements('title').single.text,
//         link: element.findElements('link').single.text,
//         description: parsedDescription,
//         imageUrl: element.findElements('thumbimage').isNotEmpty
//             ? element.findElements('thumbimage').first.text
//             : element.findElements('media:thumbnail').isNotEmpty
//                 ? element
//                         .findElements('media:thumbnail')
//                         .first
//                         .getAttribute('url') ??
//                     ''
//                 : element.findElements('media:content').isNotEmpty
//                     ? element
//                             .findElements('media:content')
//                             .first
//                             .getAttribute('url') ??
//                         ''
//                     : element.findElements('image').isNotEmpty
//                         ? element
//                                 .findElements('image')
//                                 .first
//                                 .findElements('url')
//                                 .isNotEmpty
//                             ? element
//                                 .findElements('image')
//                                 .first
//                                 .findElements('url')
//                                 .single
//                                 .text
//                             : ''
//                         : '',
//         author: element.findElements('author').isNotEmpty
//             ? element.findElements('author').single.text
//             : 'Unknown Author',
//         source_name: element.findElements('source').isNotEmpty
//             ? element.findElements('source').single.text
//             : 'open Source',
//         category: element.findElements('category').isNotEmpty
//             ? element.findElements('category').single.text
//             : 'General Category');
//   }

//   static String parseHtmlString(String htmlString) {
//     var document = html_parser.parse(htmlString);
//     return document.body?.text ?? htmlString;
//   }
// }
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

  NewsItem({
    required this.title,
    required this.link,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.sourceName,
    required this.category,
  });

  factory NewsItem.fromXml(xml.XmlElement element) {
    // Helper to get text from XML elements with a default fallback
    String getElementText(String tag, {String defaultValue = ''}) {
      final foundElements = element.findElements(tag);
      return foundElements.isNotEmpty ? foundElements.first.text : defaultValue;
    }

    // Helper to get an attribute value with a default fallback
    String getElementAttribute(String tag, String attribute,
        {String defaultValue = ''}) {
      final foundElements = element.findElements(tag);
      return foundElements.isNotEmpty
          ? foundElements.first.getAttribute(attribute) ?? defaultValue
          : defaultValue;
    }

    // Parse the raw description HTML to extract plain text
    String rawDescription = getElementText('description');
    String parsedDescription = parseHtmlString(rawDescription);

    // Determine the image URL based on available tags
    String imageUrl = getElementText('thumbimage') ??
        getElementAttribute('media:thumbnail', 'url') ??
        getElementAttribute('media:content', 'url') ??
        (element.findElements('image').isNotEmpty &&
                element
                    .findElements('image')
                    .first
                    .findElements('url')
                    .isNotEmpty
            ? element.findElements('image').first.findElements('url').first.text
            : '');

    return NewsItem(
      title: getElementText('title'),
      link: getElementText('link'),
      description: parsedDescription,
      imageUrl: imageUrl,
      author: getElementText('author', defaultValue: 'Unknown Author'),
      sourceName: getElementText('source', defaultValue: 'Open Source'),
      category: getElementText('category', defaultValue: 'General Category'),
    );
  }

  // Parses HTML content and extracts plain text
  static String parseHtmlString(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body?.text ?? htmlString;
  }
}
