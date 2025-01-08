//import 'package:flutter/material.dart';

class PlantModel {
  final int id;
  final String nameplants;
  final String codeplant;

  PlantModel({
    required this.id,
    required this.nameplants,
    required this.codeplant,
  });

  // Method untuk parsing dari JSON
  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'],
      nameplants: json['plant_name'],
      codeplant: json['plant_code'],
    );
  }
}
