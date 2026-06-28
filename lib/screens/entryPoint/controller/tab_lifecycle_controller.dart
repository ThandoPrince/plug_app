import 'package:flutter/material.dart';

class TabLifecycleController with ChangeNotifier {
  final Set<int> _loadedTabs = {};

  bool isLoaded(int tab) => _loadedTabs.contains(tab);

  void markLoaded(int tab) {
    _loadedTabs.add(tab);
    notifyListeners();
  }

  void reset() {
    _loadedTabs.clear();
    notifyListeners();
  }
}