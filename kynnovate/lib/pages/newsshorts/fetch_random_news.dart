import 'dart:math';
import 'news_item.dart';

List<NewsItem> fetchRandomNews(List<NewsItem> allNews) {
  final random = Random();
  allNews.shuffle(random);
  return allNews.take(5).toList();
}
