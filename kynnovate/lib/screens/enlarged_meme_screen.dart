import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class EnlargedMemeScreen extends StatefulWidget {
  final String imageUrl;
  final String sourceLink;

  EnlargedMemeScreen({required this.imageUrl, required this.sourceLink});

  @override
  _EnlargedMemeScreenState createState() => _EnlargedMemeScreenState();
}

class _EnlargedMemeScreenState extends State<EnlargedMemeScreen> {
  int _likeCount = 0;

  void _incrementLike() {
    setState(() {
      _likeCount++;
    });
  }

  Future<void> _shareMeme() async {
    try {
      // Download the image file
      final cacheManager = DefaultCacheManager();
      final file = await cacheManager.getSingleFile(widget.imageUrl);

      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        text: 'Check out this meme! \nSource: ${widget.sourceLink}',
      );
    } catch (e) {
      print('Error sharing meme: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share the meme. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meme Viewer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Image.network(widget.imageUrl, fit: BoxFit.contain),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Source: ${widget.sourceLink}',
                style: TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                    // children: [
                    //   IconButton(
                    //     icon: Icon(Icons.thumb_up),
                    //     onPressed: _incrementLike,
                    //   ),
                    //   Text(
                    //     '$_likeCount',
                    //     style: TextStyle(fontSize: 16),
                    //   ),
                    // ],
                    ),
                SizedBox(width: 20),
                Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: _shareMeme,
                    ),
                    Text(
                      'Share',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
