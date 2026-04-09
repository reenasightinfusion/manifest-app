import 'dart:convert';
import 'package:flutter/material.dart';
import 'api_service.dart';

class ManifestProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _currentPlan;
  Map<String, dynamic>? get currentPlan => _currentPlan;

  Map<String, dynamic>? _fullAi;
  Map<String, dynamic>? get fullAi => _fullAi;

  List<dynamic> _actionCards = [];
  List<dynamic> get actionCards => _actionCards;

  String _activeGoal = '';
  String get activeGoal => _activeGoal;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFocused = false;
  bool get isFocused => _isFocused;

  void setFocused(bool value) {
    _isFocused = value;
    notifyListeners();
  }

  Future<void> generateManifestationPlan(String userId, String goal) async {
    if (goal.trim().isEmpty) return;

    _isLoading = true;
    _currentPlan = null;
    _actionCards = [];
    _fullAi = null;
    _activeGoal = goal.trim();
    notifyListeners();

    try {
      final data = await _apiService.generatePlan(userId, goal.trim());
      _currentPlan = data['plan'];
      _actionCards = data['cards'] ?? [];
      _fullAi = data['full_ai'];
    } catch (e) {
      debugPrint('Plan Generation Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<dynamic> _history = [];
  List<dynamic> get history => _history;

  Future<void> loadHistory(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _history = await _apiService.getManifestationHistory(userId);
    } catch (e) {
      debugPrint('History Load Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void restoreHistoricalPlan(Map<String, dynamic> historyItem) {
    if (historyItem['manifestation_plans'] != null &&
        historyItem['manifestation_plans'].isNotEmpty) {
      final plan = historyItem['manifestation_plans'][0];
      _currentPlan = plan;
      List<dynamic> restoredCards = plan['daily_tasks'] ?? [];
      _activeGoal = historyItem['goal_title'] ?? '';

      // Attempt to restore `fullAi` mock format from `full_content` if available
      try {
        if (plan['full_content'] != null) {
          _fullAi = jsonDecode(plan['full_content']);
          
          // SELF-HEALING: If DB rejected the tasks because of schema errors, rebuild them instantly!
          if (restoredCards.isEmpty && _fullAi != null && _fullAi!['pillars'] != null) {
            restoredCards = (_fullAi!['pillars'] as List).asMap().entries.map((entry) {
              return {
                'day_number': entry.key + 1,
                'task_title': entry.value['title'],
                'task_description': entry.value['huge_text'],
                'task_summary': entry.value['summary']
              };
            }).toList();
          }
        }
      } catch (_) {}

      _actionCards = restoredCards;
      notifyListeners();
    }
  }

  Future<bool> deleteHistoryItem(String manifestationId) async {
    try {
      final success = await _apiService.deleteManifest(manifestationId);
      if (success) {
        _history.removeWhere((item) => item['id'].toString() == manifestationId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      debugPrint('Delete error: $e');
      return false;
    }
  }

  void clearPlan() {
    _currentPlan = null;
    _actionCards = [];
    _fullAi = null;
    notifyListeners();
  }
}
