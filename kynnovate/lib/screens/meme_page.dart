import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import 'enlarged_meme_screen.dart';

class MemePage extends StatefulWidget {
  @override
  _MemePageState createState() => _MemePageState();
}

class _MemePageState extends State<MemePage> {
  Future<List<Meme>> _fetchMemes() async {
    List<String> rssUrls = [
      'https://tamil.oneindia.com/rss/feeds/tamil-memes-fb.xml',
      'https://feeds.feedburner.com/Hindu_Tamil_cartoon'
    ];

    List<Meme> allMemes = [];

    for (String url in rssUrls) {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final document = xml.XmlDocument.parse(response.body);
        final items = document.findAllElements('item');
        allMemes.addAll(items.map((item) {
          String? imageUrl;
          String? sourceLink;

          final mediaContent = item.findElements('media:content').firstOrNull;
          if (mediaContent != null) {
            imageUrl = mediaContent.getAttribute('url');
          }

          if (imageUrl == null || imageUrl.isEmpty) {
            final content = item.findElements('content:encoded').firstOrNull;
            if (content != null) {
              final contentString = content.text;
              final regex = RegExp(r'<img src="([^"]+)"');
              final match = regex.firstMatch(contentString);
              if (match != null) {
                imageUrl = match.group(1);
              }
              final sourceRegex = RegExp(r'<a[^>]+href="([^"]+)"[^>]*>Source');
              final sourceMatch = sourceRegex.firstMatch(contentString);
              if (sourceMatch != null) {
                sourceLink = sourceMatch.group(1);
              }
            }
          }

          final title = item.findElements('title').first.text;
          return Meme(
              imageUrl: imageUrl ?? '',
              sourceLink: sourceLink ?? '',
              name: title);
        }).toList());
      } else {
        throw Exception('Failed to load memes from $url');
      }
    }
    return allMemes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memes Section'),
      ),
      body: FutureBuilder<List<Meme>>(
        future: _fetchMemes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GridView.builder(
              padding: EdgeInsets.all(10.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10.0,
                mainAxisSpacing: 10.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final meme = snapshot.data![index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EnlargedMemeScreen(
                          imageUrl: meme.imageUrl,
                          sourceLink: meme.sourceLink,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        image: DecorationImage(
                          image: NetworkImage(meme.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class Meme {
  final String imageUrl;
  final String sourceLink;
  final String name;

  Meme({required this.imageUrl, required this.sourceLink, required this.name});

  factory Meme.fromJson(Map<String, dynamic> json) {
    return Meme(
      imageUrl: json['url'],
      sourceLink: json['sourceLink'],
      name: json['name'],
    );
  }
}
