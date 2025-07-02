import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  textTheme: TextTheme(
    bodyMedium: const TextStyle(
        fontSize: 18, color: Color.fromARGB(255, 230, 219, 219)),
    bodyLarge: TextStyle(fontSize: 16, color: Colors.grey[700]),
  ),
);
