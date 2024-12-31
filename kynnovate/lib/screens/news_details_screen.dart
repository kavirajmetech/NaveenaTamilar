import 'package:flutter/material.dart';
import 'package:kynnovate/Models/news_item.dart'; // Assuming you have a class called NewsItem

class NewsDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  NewsDetailScreen({required this.newsItem});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool isLiked = false; // Default state is "not liked"

  // Function to toggle the like state
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    // Call a placeholder function to update the like status in Firebase
    updateLikeInFirebase(widget.newsItem);
  }

  // Empty function to update like status in Firebase
  Future<void> updateLikeInFirebase(NewsItem newsItem) async {
    // Placeholder for Firebase update logic in the future
    print("Updating like status in Firebase for ${newsItem.title}");
  }

  // Dummy function for the Read More button
  void dummyReadMore() {
    // Placeholder for future URL launching functionality
    print("Read More button pressed, but URL functionality is disabled for now.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Back button
        ),
        title: Text(widget.newsItem.title),
      ),
      body: Stack(  // Use a stack to layer the background image and content
        children: [
          // Background image (centered and scaled)
          Positioned.fill(
            child: Image.network(
              widget.newsItem.imageUrl,
              fit: BoxFit.cover,  // Ensure the image covers the area
              alignment: Alignment.center,  // Focus on the center
            ),
          ),
          // White transparent overlay to ensure text visibility
          Positioned.fill(
            child: Container(
              color: Colors.grey.withOpacity(0.3), // White
            ),
          ),
          // Content on top of the background image
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.newsItem.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,  // Black for the title
                    ),
                  ),
                  SizedBox(height: 8),
                  // Description
                  Text(
                    widget.newsItem.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,  // White for the description
                    ),
                  ),
                  SizedBox(height: 16),  // Add some space before the like button
                  // Like button with Heart icon
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: toggleLike,  // Toggle like on press
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,  // Change heart icon based on the like state
                        color: isLiked ? Colors.red : Colors.grey,  // Color change when liked
                      ),
                      label: Text(isLiked ? 'Liked' : 'Like'),
                    ),
                  ),
                  SizedBox(height: 16),
                  // "Read More" button (Dummy)
                  Center(
                    child: ElevatedButton(
                      onPressed: dummyReadMore,  // Placeholder function
                      child: Text('Read More'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
