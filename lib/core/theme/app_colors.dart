import 'package:flutter/material.dart';

class AppColors {
  // Brand - Deep & Premium
  static const primary = Color(0xFF6366F1); // Indigo
  static const primaryLight = Color(0xFFEEF2FF);
  static const secondary = Color(0xFF10B981); // Emerald
  static const secondaryLight = Color(0xFFECFDF5);

  // Semantic
  static const income = Color(0xFF10B981);
  static const expense = Color(0xFFEF4444);     // Rose/Red
  static const savings = Color(0xFF3B82F6);     // Blue
  static const warning = Color(0xFFF59E0B);     // Amber

  // Neutral - Grays based on Slate palette
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const divider = Color(0xFFE2E8F0);

  // Dark Mode Palette
  static const darkBackground = Color(0xFF020617);
  static const darkSurface = Color(0xFF1E293B);

  // Category colors with softer shades
  static const categoryColors = {
    'food':           Color(0xFFF97316),
    'transport':      Color(0xFF06B6D4),
    'shopping':       Color(0xFFD946EF),
    'health':         Color(0xFF10B981),
    'bills':          Color(0xFFF59E0B),
    'salary':         Color(0xFF8B5CF6),
    'savings':        Color(0xFF3B82F6),
    'entertainment':  Color(0xFFF43F5E),
    'other':          Color(0xFF94A3B8),
  };
}