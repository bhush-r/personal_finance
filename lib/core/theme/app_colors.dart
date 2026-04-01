import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFFEEEDFE);
  static const secondary = Color(0xFF1D9E75);
  static const secondaryLight = Color(0xFFE1F5EE);

  // Semantic
  static const income = Color(0xFF1D9E75);      // green
  static const expense = Color(0xFFD85A30);     // coral/red
  static const savings = Color(0xFF378ADD);     // blue
  static const warning = Color(0xFFBA7517);     // amber

  // Neutral
  static const surface = Color(0xFFF8F8F8);
  static const card = Color(0xFFFFFFFF);
  static const divider = Color(0xFFEEEEEE);

  // Category colors
  static const categoryColors = {
    'food':           Color(0xFFD85A30),
    'transport':      Color(0xFF378ADD),
    'shopping':       Color(0xFF9C59D1),
    'health':         Color(0xFF1D9E75),
    'bills':          Color(0xFFBA7517),
    'salary':         Color(0xFF1D9E75),
    'savings':        Color(0xFF185FA5),
    'entertainment':  Color(0xFFD4537E),
    'other':          Color(0xFF888780),
  };
}