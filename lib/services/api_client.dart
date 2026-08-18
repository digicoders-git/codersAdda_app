import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:coders_adda_app/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:coders_adda_app/services/api_urls.dart';
import 'package:provider/provider.dart';
import 'package:coders_adda_app/veiw_model/profile_viewmodel.dart';

class ApiClient {
  final _storage = const FlutterSecureStorage();
  final _client = http.Client();

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
      final response = await _client.get(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
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
      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
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
      final response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));
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
      final response = await _client.delete(Uri.parse(url), headers: headers).timeout(const Duration(seconds: 30));
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
      case 404:
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey('message')) {
            return body;
          }
        } catch (_) {}
        throw Exception('Error: ${response.body}');
      case 401:
      case 403:
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body['code'] == 'USER_BLOCKED') {
            _handleBlockedUser(body['message']);
            throw Exception('Unauthorized: ${body['message']}');
          }
        } catch (_) {}
        throw Exception('Unauthorized: Please login again');
      case 500:
        throw Exception('Internal Server Error');
      default:
        throw Exception('Error occurred with status code: ${response.statusCode}');
    }
  }

  void _handleBlockedUser(String message) {
    String userName = '';
    String userEmail = '';
    String userMobile = '';
    final context = navigatorKey.currentContext;
    if (context != null) {
      try {
        final profileVM = Provider.of<ProfileViewModel>(context, listen: false);
        userName = profileVM.user?.name ?? '';
        userEmail = profileVM.user?.email ?? '';
        userMobile = profileVM.user?.mobile ?? '';
      } catch (e) {}
    }

    deleteToken(); // Logout
    if (context != null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Account Blocked', style: TextStyle(color: Colors.red)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the current alert dialog
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => _UnblockRequestDialog(
                      initialName: userName,
                      initialEmail: userEmail,
                      initialMobile: userMobile,
                    ),
                  );
                },
                child: const Text("Ask for Help"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
                child: const Text("Okay"),
              )
            ],
          );
        }
      );
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

class _UnblockRequestDialog extends StatefulWidget {
  final String initialName;
  final String initialEmail;
  final String initialMobile;

  const _UnblockRequestDialog({
    Key? key,
    required this.initialName,
    required this.initialEmail,
    required this.initialMobile,
  }) : super(key: key);

  @override
  State<_UnblockRequestDialog> createState() => _UnblockRequestDialogState();
}

class _UnblockRequestDialogState extends State<_UnblockRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _mobileController;
  final _messageController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _emailController = TextEditingController(text: widget.initialEmail);
    _mobileController = TextEditingController(text: widget.initialMobile);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final body = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'category': 'Technical Problem',
        'subject': 'Account Unblock Request',
        'message': _messageController.text.trim(),
        'source': 'App'
      };
      
      final response = await ApiClient().post(ApiUrls.createSupportTicket, body);
      setState(() => _isSubmitting = false);
      
      if (mounted) {
        Navigator.pop(context); // Close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unblock request submitted successfully. Admin will review it.'), backgroundColor: Colors.green),
        );
        // Navigate to login after submission
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request Unblock', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Please provide your details. Admin will review your request and unblock your account.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mobileController,
                decoration: const InputDecoration(labelText: 'Mobile (Optional)', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(labelText: 'Reason for unblock', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
          child: _isSubmitting 
            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
            : const Text('Submit Request'),
        ),
      ],
    );
  }
}
