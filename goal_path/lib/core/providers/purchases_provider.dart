import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

// ДОБАВИЛИ: purchases бир жерде сакталат — ChecklistScreen жана AnalyticsScreen колдонот
class PurchasesProvider extends ChangeNotifier {
  final Box _box = Hive.box('purchases');
  List<Map<String, dynamic>> _purchases = [];

  // Тизме — окуу гана
  List<Map<String, dynamic>> get purchases => List.unmodifiable(_purchases);

  PurchasesProvider() {
    _loadFromHive();
  }

  void _loadFromHive() {
    final data = _box.get('items', defaultValue: []);
    _purchases = (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    notifyListeners();
  }

  void _saveToHive() {
    _box.put('items', _purchases);
  }

  // Кошуу
  void addPurchase(Map<String, dynamic> item) {
    _purchases.add(item);
    _saveToHive();
    notifyListeners(); // экрандарды кайра build кылат
  }

  // Редактирлөө
  void updatePurchase(int index, Map<String, dynamic> item) {
    _purchases[index] = item;
    _saveToHive();
    notifyListeners();
  }

  // Жок кылуу
  void deletePurchase(int index) {
    _purchases.removeAt(index);
    _saveToHive();
    notifyListeners();
  }
}