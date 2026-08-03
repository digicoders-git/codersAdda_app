import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_urls.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JobApplicationService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> applyForJob(String jobId, Map<String, dynamic> formData, String? resumePath) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception("User not authenticated");

      var request = http.MultipartRequest('POST', Uri.parse(ApiUrls.applyJobUrl));
      request.headers['Authorization'] = 'Bearer $token';

      // Add text fields
      formData.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      request.fields['jobId'] = jobId;

      // Add resume file
      if (resumePath != null && resumePath.isNotEmpty) {
        var resumeFile = await http.MultipartFile.fromPath('resume', resumePath);
        request.files.add(resumeFile);
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to submit application');
      }
    } catch (e) {
      print('JobApplicationService - applyForJob Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMyApplications() async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception("User not authenticated");

      final response = await http.get(
        Uri.parse(ApiUrls.myJobApplicationsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch applications');
      }
    } catch (e) {
      print('JobApplicationService - getMyApplications Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> withdrawApplication(String applicationId) async {
    try {
      final token = await _storage.read(key: 'auth_token');
      if (token == null) throw Exception("User not authenticated");

      final response = await http.delete(
        Uri.parse('${ApiUrls.withdrawJobApplicationUrl}/$applicationId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        var errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to withdraw application');
      }
    } catch (e) {
      print('JobApplicationService - withdrawApplication Error: $e');
      rethrow;
    }
  }
}
