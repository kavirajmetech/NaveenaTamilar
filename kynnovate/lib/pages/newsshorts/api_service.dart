import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String> fetchAIImage(String prompt) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/generate-image'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'prompt': prompt,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['image_url'];
  } else {
    throw Exception('Failed to fetch AI image');
  }
}
