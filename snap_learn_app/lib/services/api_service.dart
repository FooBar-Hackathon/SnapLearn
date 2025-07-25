import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl =
      'https://b44c85d61e51.ngrok-free.app/api'; // Change to your backend URL

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/Auth/Login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('Non-JSON response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    } else {
      print('Error response body: ${response.body}');
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Login failed.');
        }
      } catch (e) {
        print('Non-JSON error response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    }
  }

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String language,
  ) async {
    final url = Uri.parse('$baseUrl/Auth/Register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userName': username,
        'email': email,
        'password': password,
        'language': language,
      }),
    );
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        print('Non-JSON response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    } else {
      print('Error response body: ${response.body}');
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Registration failed.');
        }
      } catch (e) {
        print('Non-JSON error response: ${response.body}');
        throw Exception(
          e ??
              'Unexpected server response. Please check your connection or try again later.',
        );
      }
    }
  }

  static Future<Map<String, dynamic>> analyzeImage(File image) async {
    final url = Uri.parse('$baseUrl/Vision/analyze');
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        // Return all fields: objects, text, facts, quizzes, image
        return Map<String, dynamic>.from(data);
      } catch (e) {
        print('Non-JSON response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    } else {
      print('Error response body: ${response.body}');
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Vision analysis failed.');
        }
      } catch (e) {
        print('Non-JSON error response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    }
  }

  static Future<Map<String, dynamic>> getFacts(
    String topic,
    String difficulty,
  ) async {
    final url = Uri.parse(
      '$baseUrl/Quiz/facts/${Uri.encodeComponent(topic)}/${Uri.encodeComponent(difficulty)}',
    );
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );
    print('Facts API Response: ${response.body}'); // Debug log
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        // Backend returns { "summary": "...", "facts": [...] }
        if (data is Map<String, dynamic> &&
            data.containsKey('summary') &&
            data.containsKey('facts')) {
          return data;
        } else {
          print('Unexpected facts response format: $data'); // Debug log
          throw Exception('Invalid facts response format.');
        }
      } catch (e) {
        print('Non-JSON response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    } else {
      print('Error response body: ${response.body}');
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Failed to fetch facts.');
        }
      } catch (e) {
        print('Non-JSON error response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    }
  }

  static Future<Map<String, dynamic>> generateQuiz(
    String topic,
    String difficulty,
  ) async {
    final url = Uri.parse('$baseUrl/Quiz/generate');
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'topic': topic,
        'difficulty': difficulty,
        'questionCount': 5,
        'language': 'en',
      }),
    );
    print('Quiz Generate API Response: ${response.body}'); // Debug log
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        // Backend returns QuizDto with questions containing options and correct answers
        if (data is Map && data['questions'] is List) {
          return Map<String, dynamic>.from(data);
        } else {
          print('Unexpected quiz response format: $data'); // Debug log
          throw Exception('Invalid quiz response format.');
        }
      } catch (e) {
        print('Non-JSON response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    } else {
      print('Error response body: ${response.body}');
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Quiz generation failed.');
        }
      } catch (e) {
        print('Non-JSON error response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    }
  }

  static Future<Map<String, dynamic>> submitQuiz(
    List<Map<String, String>> answers,
    String difficulty,
    String quizId, // Add quizId as a required parameter
  ) async {
    final url = Uri.parse('$baseUrl/Quiz/submit');
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    // Convert answers to match backend UserAnswer structure
    final backendAnswers = answers
        .map(
          (answer) => {
            'question': answer['question'] ?? '',
            'selected': answer['selected'] ?? '',
          },
        )
        .toList();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'quizId': quizId,
        'answers': backendAnswers,
        'difficulty': difficulty,
      }),
    );
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['correct'] != null) {
          return Map<String, dynamic>.from(data);
        } else {
          throw Exception('Invalid quiz result format.');
        }
      } catch (e) {
        print('Non-JSON response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    } else {
      print('Error response body: ${response.body}');
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Quiz submission failed.');
        }
      } catch (e) {
        print('Non-JSON error response: ${response.body}');
        throw Exception(
          'Unexpected server response. Please check your connection or try again later.',
        );
      }
    }
  }

  // Generic GET helper
  static Future<Map<String, dynamic>> get(Uri url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Unexpected server response.');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Request failed.');
        }
      } catch (e) {
        throw Exception('Unexpected server response.');
      }
    }
  }

  // Generic POST helper
  static Future<Map<String, dynamic>> post(
    Uri url, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body ?? {}),
    );
    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        throw Exception('Unexpected server response.');
      }
    } else {
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['error'] != null) {
          throw Exception(error['error']);
        } else {
          throw Exception('Request failed.');
        }
      } catch (e) {
        throw Exception('Unexpected server response.');
      }
    }
  }

  static Future<String?> getUserId() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) return null;
    // Try /User/user-profile first
    final url = Uri.parse('$baseUrl/User/user-profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('User profile response: ${response.body}');
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        final userId = data['userId'] ?? data['id'];
        if (userId != null && userId.toString().isNotEmpty) {
          await storage.write(key: 'userId', value: userId.toString());
          return userId.toString();
        }
      } catch (_) {}
    }
    // Fallback: try /Profile
    final profileUrl = Uri.parse('$baseUrl/Profile');
    final profileResp = await http.get(
      profileUrl,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    print('Profile response: ${profileResp.body}');
    if (profileResp.statusCode == 200) {
      try {
        final data = jsonDecode(profileResp.body);
        final userId = data['userId'] ?? data['id'];
        if (userId != null && userId.toString().isNotEmpty) {
          await storage.write(key: 'userId', value: userId.toString());
          return userId.toString();
        }
      } catch (_) {}
    }
    return null;
  }

  static Future<String?> getStoredUserId() async {
    final storage = const FlutterSecureStorage();
    return await storage.read(key: 'userId');
  }

  static Future<bool> checkTokenValidity() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) return false;
    final url = Uri.parse('$baseUrl/Auth/check-token-validity');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 200;
  }

  static Future<void> logout() async {
    final storage = const FlutterSecureStorage();
    await storage.deleteAll();
  }

  static Future<void> storeProfile(Map<String, dynamic> profile) async {
    final storage = const FlutterSecureStorage();
    if (profile['userId'] != null) {
      await storage.write(key: 'userId', value: profile['userId'].toString());
    }
    await storage.write(key: 'profile', value: jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getStoredProfile() async {
    final storage = const FlutterSecureStorage();
    final profileStr = await storage.read(key: 'profile');
    if (profileStr == null) return null;
    try {
      return jsonDecode(profileStr);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getProfile() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) return null;
    final url = Uri.parse('$baseUrl/Profile');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        await storeProfile(data);
        return Map<String, dynamic>.from(data);
      } catch (e) {
        print('Non-JSON profile response: ${response.body}');
        return null;
      }
    }
    print('Profile fetch failed: ${response.body}');
    return null;
  }

  static Future<void> updateProfile({
    required String userName,
    required String language,
    required String aiPersonality,
  }) async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    if (token == null || token.isEmpty) throw Exception('Not authenticated');
    final url = Uri.parse('$baseUrl/Profile/update');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userName': userName,
        'language': language,
        'aiPersonality': aiPersonality,
      }),
    );
    if (response.statusCode != 200) {
      print('Profile update failed: ${response.body}');
      throw Exception('Failed to update profile');
    }
  }
}
