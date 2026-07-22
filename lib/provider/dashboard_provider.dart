import 'package:flutter/foundation.dart';

class DashboardProvider extends ChangeNotifier {
  int _selectedTab = 0;
  int _communicationTab = 0;
  String _selectedPeriod = 'This Month';

  int get selectedTab => _selectedTab;
  int get communicationTab => _communicationTab;
  String get selectedPeriod => _selectedPeriod;

  static const List<String> periods = [
    'Today',
    'This Week',
    'This Month',
    'This Quarter',
    'This Year',
  ];

  static const List<String> tabTitles = [
    'Dashboard',
    'Leads',
    'Tasks',
    'Reports',
    'More',
  ];

  String get selectedTitle => tabTitles[_selectedTab];

  void selectTab(int index) {
    if (index == _selectedTab || index < 0 || index >= tabTitles.length) {
      return;
    }

    _selectedTab = index;
    notifyListeners();
  }

  void setCommunicationTab(int index) {
    if (_communicationTab == index) return;
    _communicationTab = index;
    notifyListeners();
  }

  void setPeriod(String period) {
    if (_selectedPeriod == period) return;
    _selectedPeriod = period;
    notifyListeners();
  }
}
