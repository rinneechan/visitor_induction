//import 'package:flutter/material.dart';

class Visit {
  final int id;
  final String plantName;
  final String plantCode;

  Visit({
    required this.id,
    required this.plantName,
    required this.plantCode,
  });

  // Method untuk parsing dari JSON
  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      plantName: json['name_plants'],
      plantCode: json['code_plant'],
    );
  }
}
