import 'dart:convert';
import 'package:flutter/services.dart';

class EnvHelper {
  static Map<String, dynamic>? _config;

  // Fungsi untuk load file JSON
  static Future<void> loadEnv() async {
    final String response = await rootBundle.loadString('assets/env.json');
    _config = json.decode(response);
  }

  // Fungsi untuk mendapatkan value berdasarkan key
  static String get(String key) {
    return _config?[key] ?? '';
  }
}
