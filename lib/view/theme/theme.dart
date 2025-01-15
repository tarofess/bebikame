import 'package:flutter/material.dart';

ThemeData createTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.pinkAccent),
    fontFamily: 'HachiMaruPop',
    useMaterial3: true,
  );
}
