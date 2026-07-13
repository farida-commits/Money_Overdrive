import 'package:flutter/material.dart';

// ДОБАВИЛИ: purchases бир жерде сакталат — ChecklistScreen жана AnalyticsScreen колдонот
class PurchasesProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _purchases = [];

  // Тизме — окуу гана
  List<Map<String, dynamic>> get purchases => List.unmodifiable(_purchases);

  // Кошуу
  void addPurchase(Map<String, dynamic> item) {
    _purchases.add(item);
    notifyListeners(); // экрандарды кайра build кылат
  }

  // Редактирлөө
  void updatePurchase(int index, Map<String, dynamic> item) {
    _purchases[index] = item;
    notifyListeners();
  }

  // Жок кылуу
  void deletePurchase(int index) {
    _purchases.removeAt(index);
    notifyListeners();
  }
}