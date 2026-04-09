import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // 10.0.2.2 is the localhost for Android Emulators
      // For physical devices, use your computer's local IP address
      baseUrl: kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  Future<Map<String, dynamic>> saveUserProfile({
    String? id,
    required String name,
    required String avatarUrl,
    required List<String> personalAnswers,
    required List<String> familyAnswers,
    required List<String> professionalAnswers,
  }) async {
    try {
      final response = await _dio.post(
        '/api/users',
        data: {
          'id': id,
          'full_name': name,
          'avatar_url': avatarUrl,
          'personal_answers': personalAnswers,
          'family_answers': familyAnswers,
          'professional_answers': professionalAnswers,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Server returned error: ${response.data['message']}');
      }
      return response.data['data'];
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network Error: ${e.message}');
      }
      throw Exception('Cosmic Sync Error: $e');
    }
  }

  Future<Map<String, dynamic>?> searchProfileByName(String name) async {
    try {
      final response = await _dio.get(
        '/api/users/search',
        queryParameters: {'name': name},
      );

      if (response.statusCode == 200) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> generatePlan(String userId, String goal) async {
    try {
      final response = await _dio.post(
        '/api/generate-plan',
        data: {
          'user_id': userId,
          'goal_title': goal,
        },
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Failed to manifest your plan: $e');
    }
  }

  Future<List<dynamic>> getManifestationHistory(String userId) async {
    try {
      final response = await _dio.get('/api/history/$userId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      debugPrint('Failed to load history: $e');
      return [];
    }
  }

  Future<bool> deleteManifest(String manifestationId) async {
    try {
      final response = await _dio.delete('/api/manifestations/$manifestationId');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('Failed to delete manifestation: $e');
      return false;
    }
  }
}
