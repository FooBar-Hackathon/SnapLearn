import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';

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
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', image.path));
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
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

  static Future<List<String>> getFacts(String topic) async {
    final url = Uri.parse(
      '$baseUrl/Learn/facts?topic=${Uri.encodeComponent(topic)}',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        if (data is Map && data['facts'] is List) {
          return List<String>.from(data['facts']);
        } else {
          throw Exception('No facts found.');
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
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'topic': topic, 'difficulty': difficulty}),
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
    String userId,
    List<Map<String, String>> answers,
    String difficulty,
  ) async {
    final url = Uri.parse('$baseUrl/Quiz/submit');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'answers': answers,
        'difficulty': difficulty,
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
}
