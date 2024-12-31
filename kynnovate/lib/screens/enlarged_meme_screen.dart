import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

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

  void _shareMeme() {
    Share.share('Check out this meme! ${widget.imageUrl}\nSource: ${widget.sourceLink}');
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
                  children: [
                    IconButton(
                      icon: Icon(Icons.thumb_up),
                      onPressed: _incrementLike,
                    ),
                    Text(
                      '$_likeCount',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
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
