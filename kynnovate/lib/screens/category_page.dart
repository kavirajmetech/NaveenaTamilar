import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'package:kynnovate/Models/news_item.dart';

class CategoryPage extends StatelessWidget {
  final String tag;

  CategoryPage({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category: $tag'),
      ),
      body: Center(
        child: Text('News for $tag'),
      ),
    );
  }
}

// class _CategoryPageState extends State<CategoryPage> {
//   List<NewsItem> newsItems = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadNewsForTag(widget.tag);
//   }

//   Future<void> loadNewsForTag(String tag) async {
//     try {
//       // Load RSS URLs from JSON
//       String jsonString = await DefaultAssetBundle.of(context).loadString('assets/rssList.json');
//       Map<String, dynamic> rssData = json.decode(jsonString);
      
//       List<String> urls = getUrlsForTag(tag, rssData);

//       if (urls.isNotEmpty) {
//         List<NewsItem> fetchedNews = await fetchMultipleRssFeeds(urls);
//         setState(() {
//           newsItems = fetchedNews;
//           isLoading = false;
//         });
//       } else {
//         throw Exception('No RSS URLs found for tag: $tag');
//       }
//     } catch (e) {
//       print('Error loading news for tag $tag: $e');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   List<String> getUrlsForTag(String tag, Map<String, dynamic> rssData) {
//     List<String> urls = [];

//     if (rssData['categories'][tag] is List) {
//       urls = List<String>.from(rssData['categories'][tag]);
//     } else if (rssData['categories'][tag] is Map) {
//       Map<String, dynamic> subcategories = rssData['categories'][tag];
//       for (var subList in subcategories.values) {
//         urls.addAll(List<String>.from(subList));
//       }
//     }

//     return urls;
//   }

//   Future<List<NewsItem>> fetchRssFeed(String url) async {
//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final document = xml.XmlDocument.parse(response.body);
//         final items = document.findAllElements('item');
//         return items.map((element) => NewsItem.fromXml(element)).toList();
//       } else {
//         print('Failed to load RSS feed from $url (Status Code: ${response.statusCode})');
//         return [];
//       }
//     } catch (e) {
//       print('Error fetching RSS feed from $url: $e');
//       return [];
//     }
//   }

//   Future<List<NewsItem>> fetchMultipleRssFeeds(List<String> urls) async {
//     List<NewsItem> allNewsItems = [];
//     List<String> failedUrls = [];

//     for (String url in urls) {
//       try {
//         final newsItems = await fetchRssFeed(url);
//         if (newsItems.isNotEmpty) {
//           allNewsItems.addAll(newsItems);
//         } else {
//           failedUrls.add(url);
//         }
//       } catch (e) {
//         failedUrls.add(url);
//         print('Error fetching from $url: $e');
//       }
//     }

//     if (allNewsItems.isEmpty && failedUrls.isNotEmpty) {
//       throw Exception('Failed to fetch news from any source');
//     }

//     return allNewsItems;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.tag),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : newsItems.isEmpty
//               ? const Center(child: Text('No news available'))
//               : ListView.builder(
//                   itemCount: newsItems.length,
//                   itemBuilder: (context, index) {
//                     final item = newsItems[index];
//                     return ListTile(
//                       leading: item.imageUrl != null
//                           ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
//                           : const Icon(Icons.image, size: 50),
//                       title: Text(item.title ?? 'No Title'),
//                       subtitle: Text(item.description ?? 'No Description'),
//                       trailing: const Icon(Icons.arrow_forward),
//                       onTap: () {
//                         // Handle navigation or open link
//                       },
//                     );
//                   },
//                 ),
//     );
//   }
// }
