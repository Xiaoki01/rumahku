import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../routes/app_routes.dart';
import 'auth_service.dart';

class ApiService extends GetxService {
  final _storage = GetStorage();

  static const Duration _timeoutDuration = Duration(seconds: 30);

  Map<String, String> get _headers {
    final token = _storage.read(AppConstants.tokenKey);

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get _multipartHeaders {
    final token = _storage.read(AppConstants.tokenKey);
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('GET: $url');

      final response =
          await http.get(url, headers: _headers).timeout(_timeoutDuration);

      print('Response ${response.statusCode}: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      print('GET Timeout');
      throw 'Koneksi timeout. Periksa internet Anda.';
    } on SocketException {
      print('No Internet Connection');
      throw 'Tidak ada koneksi internet.';
    } catch (e) {
      print('GET Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('POST: $url');
      print('Data: $data');

      final response = await http
          .post(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(_timeoutDuration);

      print('Response ${response.statusCode}: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      print('POST Timeout');
      throw 'Koneksi timeout. Periksa internet Anda.';
    } on SocketException {
      print('No Internet Connection');
      throw 'Tidak ada koneksi internet.';
    } catch (e) {
      print('POST Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String endpoint,
    Map<String, dynamic> data, {
    required File file,
    required String fileKey,
  }) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('POST Multipart: $url');

      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(_multipartHeaders);

      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      final stream = http.ByteStream(file.openRead());
      final length = await file.length();
      final multipartFile = http.MultipartFile(
        fileKey,
        stream,
        length,
        filename: file.path.split('/').last,
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send().timeout(_timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      print('Response ${response.statusCode}: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      print('POST Multipart Timeout');
      throw 'Koneksi timeout. Periksa internet Anda.';
    } on SocketException {
      print('No Internet Connection');
      throw 'Tidak ada koneksi internet.';
    } catch (e) {
      print('POST Multipart Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('PUT: $url');
      print('Data: $data');

      final response = await http
          .put(
            url,
            headers: _headers,
            body: jsonEncode(data),
          )
          .timeout(_timeoutDuration);

      print('Response ${response.statusCode}: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      print('PUT Timeout');
      throw 'Koneksi timeout. Periksa internet Anda.';
    } on SocketException {
      print('No Internet Connection');
      throw 'Tidak ada koneksi internet.';
    } catch (e) {
      print('PUT Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final url = Uri.parse('${AppConstants.baseUrl}$endpoint');
      print('DELETE: $url');

      final response =
          await http.delete(url, headers: _headers).timeout(_timeoutDuration);

      print('Response ${response.statusCode}: ${response.body}');

      return _handleResponse(response);
    } on TimeoutException {
      print('DELETE Timeout');
      throw 'Koneksi timeout. Periksa internet Anda.';
    } on SocketException {
      print('No Internet Connection');
      throw 'Tidak ada koneksi internet.';
    } catch (e) {
      print('DELETE Error: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      } else if (response.statusCode == 401) {
        print('🔒 401 Unauthorized at ${Get.currentRoute}');

        if (Get.currentRoute != Routes.LOGIN &&
            Get.currentRoute != Routes.REGISTER &&
            Get.currentRoute != '/login' &&
            Get.currentRoute != '/register') {
          Future.delayed(Duration(milliseconds: 300), () {
            if (Get.isRegistered<AuthService>()) {
              Get.find<AuthService>().logout();
            }
          });
        }

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
        String errorMessage = data['message'] ?? 'Terjadi kesalahan';

        if (data['errors'] != null && data['errors'] is Map) {
          final errors = data['errors'] as Map;
          errorMessage = errors.values.first.toString();
        }

        throw errorMessage;
      }
    } catch (e) {
      print('❌ Response handling error: $e');
      rethrow;
    }
  }
}
