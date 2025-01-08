//import 'package:flutter/material.dart';

class Dept {
  final String namedept;
  final String codedept;

  Dept({
    required this.namedept,
    required this.codedept,
  });

  // Method untuk parsing dari JSON
  factory Dept.fromJson(Map<String, dynamic> json) {
    return Dept(
      namedept: json['department_name'],
      codedept: json['department_code'],
    );
  }
}
