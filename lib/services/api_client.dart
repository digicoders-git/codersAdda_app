import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  final _storage = const FlutterSecureStorage();

  // Helper function to get headers with Token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: 'auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET Request
  Future<dynamic> get(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse(url), headers: headers);
      return _processResponse(response);
    } on SocketException {
      throw Exception('No Internet Connection');
    } catch (e) {
      rethrow;
    }
  }

  // POST Request
  Future<dynamic> post(String url, dynamic body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('No Internet Connection');
    } catch (e) {
      rethrow;
    }
  }

  // PUT Request
  Future<dynamic> put(String url, dynamic body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      return _processResponse(response);
    } on SocketException {
      throw Exception('No Internet Connection');
    } catch (e) {
      rethrow;
    }
  }

  // Multipart PUT Request (for profile update with image)
  Future<dynamic> putMultipart(String url, Map<String, String> fields, {File? imageFile}) async {
    try {
      final token = await getToken();
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      
      // Add headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      
      // Add fields
      request.fields.addAll(fields);
      
      // Add image file if exists
      if (imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'profilePicture',
          imageFile.path,
        ));
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response);
    } on SocketException {
      throw Exception('No Internet Connection');
    } catch (e) {
      rethrow;
    }
  }

  // DELETE Request
  Future<dynamic> delete(String url) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(Uri.parse(url), headers: headers);
      return _processResponse(response);
    } on SocketException {
      throw Exception('No Internet Connection');
    } catch (e) {
      rethrow;
    }
  }

  // Process HTTP Responses
  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad Request: ${response.body}');
      case 401:
      case 403:
        // You can add logic here to logout user if token expires
        throw Exception('Unauthorized: Please login again');
      case 500:
      default:
        throw Exception('Error occurred with status code: ${response.statusCode}');
    }
  }

  // Token Management functions
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
