import 'package:flutter/material.dart';

ThemeData createDefaultTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
    fontFamily: 'HachiMaruPop',
    useMaterial3: true,
  );
}
