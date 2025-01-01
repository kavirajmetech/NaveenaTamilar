import 'package:flutter/material.dart';
import 'package:kynnovate/Models/news_item.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  NewsDetailScreen({required this.newsItem});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool isLiked = false;

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    updateLikeInFirebase(widget.newsItem);
  }

  Future<void> updateLikeInFirebase(NewsItem newsItem) async {
    print("Updating like status in Firebase for ${newsItem.title}");
  }

  void dummyReadMore() {
    print(
        "Read More button pressed, but URL functionality is disabled for now.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.newsItem.title),
      ),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.network(
              widget.newsItem.imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.grey.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Foreground content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.newsItem.title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Image.network(
                        widget.newsItem.imageUrl,
                        height: 200,
                        fit: BoxFit.contain,
                        alignment: Alignment.center,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            color: Colors.grey,
                            child: Center(
                              child: Icon(Icons.broken_image,
                                  size: 50, color: Colors.white),
                            ),
                          );
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Date: ${widget.newsItem.date}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Author: ${widget.newsItem.author}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[300],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      // Description
                      Text(
                        widget.newsItem.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "Source: ${widget.newsItem.author}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Like Button
                          ElevatedButton.icon(
                            onPressed: toggleLike,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: Colors.white,
                            ),
                            label: Text(
                              isLiked ? 'Liked' : 'Like',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: dummyReadMore,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Read More',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
