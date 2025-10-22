//import 'package:flutter/material.dart';

class InductionRequest {
  final String namedept;
  final String codedept;

  InductionRequest({
    required this.namedept,
    required this.codedept,
  });

  // Method untuk parsing dari JSON
  factory InductionRequest.fromJson(Map<String, dynamic> json) {
    return InductionRequest(
      namedept: json['department_name'],
      codedept: json['department_code'],
    );
  }
}
