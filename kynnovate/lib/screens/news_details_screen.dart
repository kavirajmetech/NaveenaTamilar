import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kynnovate/Models/news_item.dart';
import 'package:kynnovate/globals.dart'; // Assuming you have a class called NewsItem
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatefulWidget {
  final NewsItem newsItem;

  NewsDetailScreen({required this.newsItem});

  @override
  _NewsDetailScreenState createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  bool isLiked = false;

  @override
  void initState() {
    if (!globalloadedvariables) fetchUserDetails();
  }

  // Function to toggle the like state
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    updateLikeInFirebase(widget.newsItem);
  }

  Future<void> updateLikeInFirebase(NewsItem newsItem) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;

        // Add author only if it doesn't exist
        if (!globalUserData['likedauthors'].contains(newsItem.author)) {
          globalUserData['likedauthors'].add(newsItem.author);
          await FirebaseFirestore.instance
              .collection('User')
              .doc(userId)
              .update({'likedauthors': globalUserData['likedauthors']});
        }

        // Add content only if it doesn't exist
        if (!globalUserData['likedcontent'].contains(newsItem.category)) {
          globalUserData['likedcontent'].add(newsItem.category);
          await FirebaseFirestore.instance
              .collection('User')
              .doc(userId)
              .update({'likedcontent': globalUserData['likedcontent']});
        }

        // Add news channel only if it doesn't exist
        if (!globalUserData['likednewschannels']
            .contains(newsItem.sourceName)) {
          globalUserData['likednewschannels'].add(newsItem.sourceName);
          await FirebaseFirestore.instance
              .collection('User')
              .doc(userId)
              .update(
                  {'likednewschannels': globalUserData['likednewschannels']});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added successfully')),
        );
      }
    } catch (e) {
      print("Error updating item: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item')),
      );
    }

    print('Database updated');
    print("Updating like status in Firebase for ${newsItem.title}");
  }

  Future<void> openLink(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Show an error message if the URL cannot be opened
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
      throw 'Could not launch $url';
    }
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
      body: Stack(
        // Use a stack to layer the background image and content
        children: [
          // Background image (centered and scaled)
          Positioned.fill(
            child: Image.network(
              widget.newsItem.imageUrl,
              fit: BoxFit.cover, // Ensure the image covers the area
              alignment: Alignment.center, // Focus on the center
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
                      color: Colors.black, // Black for the title
                    ),
                  ),
                  SizedBox(height: 8),
                  // Description
                  Text(
                    widget.newsItem.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white, // White for the description
                    ),
                  ),
                  SizedBox(height: 16), // Add some space before the like button
                  // Like button with Heart icon
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: toggleLike, // Toggle like on press
                      icon: Icon(
                        isLiked
                            ? Icons.favorite
                            : Icons
                                .favorite_border, // Change heart icon based on the like state
                        color: isLiked
                            ? Colors.red
                            : Colors.grey, // Color change when liked
                      ),
                      label: Text(isLiked ? 'Liked' : 'Like'),
                    ),
                  ),
                  SizedBox(height: 16),
                  // "Read More" button
                  Center(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (await canLaunchUrl(
                            Uri.parse(widget.newsItem.link))) {
                          launchUrl(Uri.parse(widget.newsItem.link),
                              mode: LaunchMode.externalApplication);
                        } else {
                          launchUrl(
                              Uri.parse(
                                  'https://www.youtube.com/watch?v=__j-G-rqWlU'),
                              mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text('Read More'),
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
