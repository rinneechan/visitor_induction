//import 'package:flutter/material.dart';

class Durations {
  final int id;
  final String nameduration;

  Durations({
    required this.id,
    required this.nameduration,
  });

  // Method untuk parsing dari JSON
  factory Durations.fromJson(Map<String, dynamic> json) {
    return Durations(
      // Menggunakan nama kelas yang benar
      id: json['id'],
      nameduration: json['pass_type'],
    );
  }
}
