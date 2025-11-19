import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class UserProfile with ChangeNotifier {
  String _plantId = '';

  String get plantId => _plantId;

  void setPlantId(String id) {
    _plantId = id;
    Hive.box('userBox').put('plantId', id); // simpan ke Hive
    notifyListeners();
  }

  void loadPlantIdFromHive() {
    _plantId = Hive.box('userBox').get('plantId', defaultValue: '');
    notifyListeners();
  }
}
