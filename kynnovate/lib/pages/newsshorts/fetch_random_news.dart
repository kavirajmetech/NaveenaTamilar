import 'dart:math';
import 'package:kynnovate/Models/news_item.dart';

List<NewsItem> fetchRandomNews(List<NewsItem> allNews) {
  final random = Random();
  allNews.shuffle(random);
  return allNews.take(5).toList();
}
