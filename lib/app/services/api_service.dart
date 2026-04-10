import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      // Pointing to Live Vercel Backend
      baseUrl: 'https://manifest-backend.vercel.app',
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
    String? passcode,
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
          'passcode': passcode,
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
        data: {'user_id': userId, 'goal_title': goal},
      );
      final body = Map<String, dynamic>.from(response.data);
      // Pass through invalid-input responses so provider can show the reason
      if (body['valid'] == false) return body;
      return body['data'] ?? {};
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
      final response = await _dio.delete(
        '/api/manifestations/$manifestationId',
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      debugPrint('Failed to delete manifestation: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> generateArchetype(String userId) async {
    try {
      final response = await _dio.post(
        '/api/generate-archetype',
        data: {'user_id': userId},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to discover your archetype: $e');
    }
  }
}
