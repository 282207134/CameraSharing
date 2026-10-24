import 'package:flutter/material.dart';

abstract final class C {
  static const purple = Color(0xFF7B3FFF);
  static const navy = Color(0xFF051C3F);
  static const text = Color(0xFF243453);
  static const muted = Color(0xFF8193AE);
  static const background = Color(0xFFF6F7FB);
  static const green = Color(0xFF00C99A);
  static const lavender = Color(0xFFF0EAFF);
}

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  fontFamily: 'DMSans',
  scaffoldBackgroundColor: C.background,
  colorScheme: ColorScheme.fromSeed(
    seedColor: C.purple,
    primary: C.purple,
    surface: C.background,
  ),
  textTheme: const TextTheme(
    bodyMedium: TextStyle(color: C.text, fontSize: 15),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 19),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: C.purple),
    ),
    hintStyle: const TextStyle(color: C.muted, fontSize: 15),
    labelStyle: const TextStyle(
      color: C.text,
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
);
