import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  // ── Basic Profile ────────────────────────────────────────────────────────
  String _name = 'Alex Manifestor';
  String get name => _name;

  String _profileImage =
      'https://api.dicebear.com/7.x/avataaars/png?seed=manifest&backgroundColor=b6e3f4,c0aede,d1d4f9';
  String get profileImage => _profileImage;

  // ── Onboarding Survey Answers ──────────────────────────────────────────────
  final List<String> personalAnswers = List.filled(5, '');
  final List<String> familyAnswers = List.filled(5, '');
  final List<String> professionalAnswers = List.filled(5, '');

  // ── Focus & Navigation ────────────────────────────────────────────────
  int? _focusedQuestionIndex;
  int? get focusedQuestionIndex => _focusedQuestionIndex;

  void setFocusedQuestion(int? index) {
    _focusedQuestionIndex = index;
    notifyListeners();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _userId;
  String? get userId => _userId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString('userId');
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    
    debugPrint('INIT: userId: $_userId, loggedIn: $_isLoggedIn');

    // Safety check: If we are "logged in" but have no ID from the new system, reset.
    if (_isLoggedIn && (_userId == null || _userId!.isEmpty)) {
      _isLoggedIn = false;
      await prefs.clear();
    }
    
    _name = prefs.getString('userName') ?? 'Alex Manifestor';
    _profileImage = prefs.getString('userImage') ?? _profileImage;
    notifyListeners();
  }

  bool _showOnboardingErrors = false;
  bool get showOnboardingErrors => _showOnboardingErrors;

  void setShowOnboardingErrors(bool show) {
    _showOnboardingErrors = show;
    notifyListeners();
  }

  int _onboardingStep = 0;
  int get onboardingStep => _onboardingStep;

  void setOnboardingStep(int step) {
    _onboardingStep = step;
    _showOnboardingErrors = false;
    notifyListeners();
  }

  void updateName(String newName) {
    _name = newName;
    notifyListeners();
  }

  void updateAvatar(String url) {
    _profileImage = url;
    notifyListeners();
  }

  void updateAnswer(int step, int qIndex, String value) {
    if (step == 0) {
      personalAnswers[qIndex] = value;
      // If this is the "What is your first name?" question, update the main name
      if (qIndex == 0) {
        _name = value.isEmpty ? 'Alex Manifestor' : value;
      }
    } else if (step == 1) {
      familyAnswers[qIndex] = value;
    } else {
      professionalAnswers[qIndex] = value;
    }
    if (_showOnboardingErrors && value.trim().isNotEmpty) {
      // Check if all fields for current step are now filled to clear errors
      if (isStepComplete(_onboardingStep)) {
        _showOnboardingErrors = false;
      }
    }
    notifyListeners();
  }

  List<String> getAnswersFor(int step) {
    if (step == 0) return personalAnswers;
    if (step == 1) return familyAnswers;
    return professionalAnswers;
  }

  bool isStepComplete(int step) {
    final answers = getAnswersFor(step);
    return answers.every((a) => a.trim().isNotEmpty);
  }

  Future<void> syncToApi() async {
    _isLoading = true;
    notifyListeners();

    debugPrint('SYNCING: userId=$_userId, name=$_name');

    try {
      final data = await _apiService.saveUserProfile(
        id: _userId,
        name: _name,
        avatarUrl: _profileImage,
        personalAnswers: personalAnswers,
        familyAnswers: familyAnswers,
        professionalAnswers: professionalAnswers,
      );
      
      // Save locally after successful sync
      final prefs = await SharedPreferences.getInstance();
      _userId = data['id']; // Get ID from response
      debugPrint('SYNC SUCCESS: new userId=$_userId');
      
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', _name);
      await prefs.setString('userImage', _profileImage);
      await prefs.setString('userId', _userId!);
      _isLoggedIn = true;
    } catch (e) {
      debugPrint('SYNC ERROR: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinExistingProfile(String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _apiService.searchProfileByName(name);
      if (profile != null) {
        _userId = profile['id'];
        _name = profile['full_name'] ?? _name;
        _profileImage = profile['avatar_url'] ?? _profileImage;
        
        // Restore answers
        if (profile['personal_answers'] != null) {
          final List<dynamic> pa = profile['personal_answers'];
          for (int i = 0; i < pa.length && i < 5; i++) personalAnswers[i] = pa[i].toString();
        }
        if (profile['family_answers'] != null) {
          final List<dynamic> fa = profile['family_answers'];
          for (int i = 0; i < fa.length && i < 5; i++) familyAnswers[i] = fa[i].toString();
        }
        if (profile['professional_answers'] != null) {
          final List<dynamic> pra = profile['professional_answers'];
          for (int i = 0; i < pra.length && i < 5; i++) professionalAnswers[i] = pra[i].toString();
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userName', _name);
        await prefs.setString('userImage', _profileImage);
        await prefs.setString('userId', _userId!);
        _isLoggedIn = true;
        
        debugPrint('JOIN SUCCESS: userId=$_userId');
        notifyListeners();
        return true;
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _name = 'Alex Manifestor';
    notifyListeners();
  }
}
