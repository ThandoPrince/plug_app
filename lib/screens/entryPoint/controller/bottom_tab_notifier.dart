import 'package:flutter/material.dart';

class TabIndexNotifier with ChangeNotifier {
  int _index = 0;
  final Set<int> _visitedTabs = {};

  int get index => _index;

  bool hasVisited(int tab) => _visitedTabs.contains(tab);

  bool _scheduled = false;

  void setIndex(int index) {
    if (_index == index) return;

    _index = index;
    _visitedTabs.add(index);

    _scheduleNotify();
  }

  void _scheduleNotify() {
    if (_scheduled) return;

    _scheduled = true;

    Future.microtask(() {
      _scheduled = false;
      notifyListeners();
    });
  }

  void reset() {
    _index = 0;
    _visitedTabs.clear();
    notifyListeners();
  }
}