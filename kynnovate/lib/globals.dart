import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

String? globalUserId;
String? globalUsername;
String? globalEmail;
int? globaltheme = 1;
Map<String, dynamic> globalOptions = {};
Map<String, dynamic> globalUserData = {};
bool globalloadedvariables = false;
bool globalloadedpreferences = false;
String? globalLanguageOption = 'ta';

class ThemeNotifier extends ChangeNotifier {
  int _theme = 1;

  int get theme => _theme;

  void changeTheme(int newTheme) {
    if (_theme != newTheme) {
      _theme = newTheme;
      notifyListeners();
    }
  }
}

ThemeNotifier themeNotifier = ThemeNotifier();
