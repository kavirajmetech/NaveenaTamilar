// import 'package:xml/xml.dart' as xml;
// import 'package:html/parser.dart' as html_parser;

// class NewsItem {
//   final String title;
//   final String link;
//   final String description;
//   final String imageUrl;
//   final String author;
//   final String sourceName;
//   final String category;

//   NewsItem({
//     required this.title,
//     required this.link,
//     required this.description,
//     required this.imageUrl,
//     required this.author,
//     required this.sourceName,
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
//         sourceName: element.findElements('source').isNotEmpty
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
import 'package:intl/intl.dart';
import 'package:html/parser.dart' as htmlParser;

class NewsItem {
  final String title;
  final String link;
  final String description;
  final String imageUrl;
  final String author;
  final String sourceName;
  final String category;
  final String date;
  final String simpleDate;

  NewsItem({
    required this.title,
    required this.link,
    required this.description,
    required this.imageUrl,
    required this.author,
    required this.sourceName,
    required this.category,
    required this.date,
    required this.simpleDate
  });

  factory NewsItem.fromXml(xml.XmlElement element) {

    String getText(String tag) =>
        element.findElements(tag).firstOrNull?.text ?? '';

    String getAttribute(String tag, String attr) =>
        element.findElements(tag).firstOrNull?.getAttribute(attr) ?? '';


    String parseMediaContentThumbnail() {
      final enclosure = element.findElements('media:content').firstOrNull;
      print(enclosure);
      if (enclosure != null) {
        return enclosure.getAttribute('url') ?? 'https://picsum.photos/800?random=${DateTime.now().millisecondsSinceEpoch}';
      }
      return 'https://picsum.photos/800?random=${DateTime.now().millisecondsSinceEpoch}';
    }


// Other existing functions...



    String parseImgFromDescription() {
      final description = getText('description');

      // Parse the HTML content
      final document = htmlParser.parse((description));

      // Extract the first img tag's src attribute
      final imgTag = document.querySelector('img');
      if (imgTag != null) {
        return imgTag.attributes['src'] ?? 'https://picsum.photos/800?random=${DateTime.now().millisecondsSinceEpoch}';
      }

      return 'https://picsum.photos/800?random=${DateTime.now().millisecondsSinceEpoch}';
    }

    final imagePatterns = [
          () => getText('thumbimage'),
          () => getAttribute('media:thumbnail', 'url'),
          () => RegExp(r'<img src="([^"]+)"').firstMatch(getText('content:encoded'))?.group(1) ?? '',
          () => element.findElements('image').firstOrNull
          ?.findElements('url').firstOrNull?.text ?? '',
          () => element.findElements('media:content').firstOrNull?.getAttribute('url') ?? '',
          // () => getAttribute('media:content', 'url'),
          () => parseImgFromDescription(),
          () => parseMediaContentThumbnail(), // New function to handle media:content tag
          () => element.findElements('image').firstOrNull?.text ?? ''
    ];




    final String imageUrl = imagePatterns
        .map((pattern) => pattern())
        .firstWhere((url) => url.isNotEmpty, orElse: () => '');

    final link = getText('link');
    final author = getText('atom:author').isNotEmpty
        ? getText('atom:author')
        : getText('author').isNotEmpty
        ? getText('author')
        : getText('dc:creator').isNotEmpty
        ? getText('dc:creator')
        : '';


    final sourceName = Uri.tryParse(link)?.host ?? '';
    final date = formatDateString(getText('pubDate'));
    final simpleDate = SimpleformatDateString(getText('pubDate'));
    return NewsItem(
      title: getText('title'),
      link: link,
      description: parseHtmlString(getText('description')).isEmpty ? parseHtmlString(getText('content:encoded')) : parseHtmlString(getText('description')),
      imageUrl: imageUrl,
      author: author,
      sourceName: sourceName,
      category: getText('category'),
      date: date,
      simpleDate: simpleDate
    );
  }
  static String parseHtmlString(String htmlString) {
    var document = html_parser.parse(htmlString);
    return document.body?.text ?? htmlString;
  }
}
String SimpleformatDateString(String date) {
  try {
    final parsed = DateTime.parse(date);
    return "${parsed.year}/${parsed.month}/${parsed.day} ${parsed.hour}:${parsed.minute < 10 ? "0":""}${parsed.minute}";
  } catch (_) {
    return 'Recent News';
  }
}


String formatDateString(String date) {
  try {
    final parsed = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(date, true);
    return "${parsed.day}/${parsed.month}/${parsed.year} ${parsed.hour > 12 ? parsed.hour % 12 : parsed.hour}:${parsed.minute < 10 ? "0" : ""}${parsed.minute} ${parsed.hour >= 12 ? "PM" : "AM"}";
  } catch (_) {
    return 'Recent News';
  }
}


