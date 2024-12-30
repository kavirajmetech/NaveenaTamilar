import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'news_item.dart';
import 'api_service.dart';

class NewsSlideshow extends StatefulWidget {
  final List<NewsItem> articles;

  NewsSlideshow({required this.articles});

  @override
  _NewsSlideshowState createState() => _NewsSlideshowState();
}

class _NewsSlideshowState extends State<NewsSlideshow> {
  final FlutterTts flutterTts = FlutterTts();
  late List<String> backgroundImages;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateBackgroundImages();
  }

  Future<void> _generateBackgroundImages() async {
    List<String> images = [];
    for (var article in widget.articles) {
      try {
        final imageUrl = await fetchAIImage(article.title);
        images.add(imageUrl);
      } catch (e) {
        print('Error fetching image for ${article.title}: $e');
        images.add('');
      }
    }
    setState(() {
      backgroundImages = images;
      isLoading = false;
    });
    _speakNews(widget.articles[0].title);
  }

  void _speakNews(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return PageView.builder(
      itemCount: widget.articles.length,
      onPageChanged: (index) {
        _speakNews(widget.articles[index].title);
      },
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(backgroundImages[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                color: Colors.white.withOpacity(0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.articles[index].title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(widget.articles[index].description),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
