import 'package:flutter/material.dart';

class EnlargedMemeScreen extends StatelessWidget {
  final String imageUrl;
  final String sourceLink;

  EnlargedMemeScreen({required this.imageUrl, required this.sourceLink});

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
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Source: $sourceLink',
                style: TextStyle(color: Colors.blue),
                textAlign: TextAlign.center,
              ),
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
