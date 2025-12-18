import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  final _storage = GetStorage();

  // Get Authorization Header
  Map<String, String> get _headers {
    final token = _storage.read(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get Authorization Header for Multipart
  Map<String, String> get _multipartHeaders {
    final token = _storage.read(AppConstants.tokenKey);
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // GET Request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print(' GET: $url'); // DEBUG

      final response = await http.get(url, headers: _headers);

      print(' Response ${response.statusCode}: ${response.body}'); // DEBUG

      return _handleResponse(response);
    } catch (e) {
      print(' GET Error: $e'); // DEBUG
      throw 'Terjadi kesalahan: $e';
    }
  }

  // POST Request
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print(' POST: $url'); // DEBUG
      print(' Data: $data'); // DEBUG

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      print(' Response ${response.statusCode}: ${response.body}'); // DEBUG

      return _handleResponse(response);
    } catch (e) {
      print(' POST Error: $e'); // DEBUG
      throw 'Terjadi kesalahan: $e';
    }
  }

  // POST Multipart Request (untuk upload file)
  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    required File file, // REQUIRED
    required String fileKey, // REQUIRED
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print(' POST Multipart: $url'); // DEBUG
      print(' Data: $data'); // DEBUG
      print(' File: ${file.path}'); // DEBUG
      print(' File Key: $fileKey'); // DEBUG

      final request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers.addAll(_multipartHeaders);
      print(' Headers: ${request.headers}'); // DEBUG

      // Add fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      print(' Fields: ${request.fields}'); // DEBUG

      // Add file
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        fileKey,
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);
      print(
          '📎 File added: ${multipartFile.filename} (${multipartFile.length} bytes)'); // DEBUG

      // Send request
      print(' Sending multipart request...'); // DEBUG
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print(' Response ${response.statusCode}: ${response.body}'); // DEBUG

      return _handleResponse(response);
    } catch (e) {
      print(' POST Multipart Error: $e'); // DEBUG
      throw 'Terjadi kesalahan: $e';
    }
  }

  // PUT Request
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print(' PUT: $url'); // DEBUG
      print(' Data: $data'); // DEBUG

      final response = await http.put(
        url,
        headers: _headers,
        body: jsonEncode(data),
      );

      print('📥 Response ${response.statusCode}: ${response.body}'); // DEBUG

      return _handleResponse(response);
    } catch (e) {
      print(' PUT Error: $e'); // DEBUG
      throw 'Terjadi kesalahan: $e';
    }
  }

  // DELETE Request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('🌐 DELETE: $url'); // DEBUG

      final response = await http.delete(url, headers: _headers);

      print('📥 Response ${response.statusCode}: ${response.body}'); // DEBUG

      return _handleResponse(response);
    } catch (e) {
      print('❌ DELETE Error: $e'); // DEBUG
      throw 'Terjadi kesalahan: $e';
    }
  }

  // Handle Response
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else if (response.statusCode == 401) {
        // Token expired or invalid
        Get.find<AuthService>().logout();
        Get.snackbar(
          'Sesi Berakhir',
          'Silakan login kembali',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        throw 'Unauthorized';
      } else if (response.statusCode == 403) {
        Get.snackbar(
          'Akses Ditolak',
          data['message'] ?? 'Anda tidak memiliki akses',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        throw 'Forbidden';
      } else if (response.statusCode >= 500) {
        Get.dialog(
          AlertDialog(
            title: const Text('Server Error'),
            content: Text(data['message'] ?? 'Terjadi kesalahan pada server'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        throw 'Server Error';
      } else {
        // Handle validation errors
        String errorMessage = data['message'] ?? 'Terjadi kesalahan';

        // If there are validation errors, show them
        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          errorMessage = errors.values.first.toString();
        }

        throw errorMessage;
      }
    } catch (e) {
      print(' Response handling error: $e'); // DEBUG
      rethrow;
    }
  }
}
