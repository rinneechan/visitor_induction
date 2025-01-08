//import 'package:flutter/material.dart';

class Visit {
  final int id;
  final String nameplants;
  final String codeplant;

  Visit({
    required this.id,
    required this.nameplants,
    required this.codeplant,
  });

  // Method untuk parsing dari JSON
  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      nameplants: json['name_plants'],
      codeplant: json['code_plant'],
    );
  }
}
