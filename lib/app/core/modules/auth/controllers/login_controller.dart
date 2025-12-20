import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final ApiService apiService = Get.find<ApiService>();
  final AuthService authService = Get.find<AuthService>();

  final email = ''.obs;
  final password = ''.obs;
  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  bool get isEmailValid => GetUtils.isEmail(email.value.trim());
  bool get isPasswordValid => password.value.isNotEmpty;
  bool get isFormValid => isEmailValid && isPasswordValid;

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  void updateEmail(String value) {
    email.value = value;
  }

  void updatePassword(String value) {
    password.value = value;
  }

  Future<void> login() async {
    if (!_validateForm()) return;

    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final response = await apiService.post(
        AppConstants.loginEndpoint,
        {
          'email': email.value.trim(),
          'password': password.value,
        },
      );

      if (response['status'] == 'success') {
        final token = response['data']['token'];
        final user = UserModel.fromJson(response['data']['user']);

        await authService.saveLoginData(token, user);

        _showSuccess('Login berhasil! Selamat datang, ${user.name}');

        _clearForm();

        await Future.delayed(const Duration(milliseconds: 500));

        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        _showError(response['message'] ?? 'Login gagal');
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (email.value.trim().isEmpty) {
      _showError('Email tidak boleh kosong');
      return false;
    }

    if (!isEmailValid) {
      _showError('Format email tidak valid');
      return false;
    }

    if (password.value.isEmpty) {
      _showError('Password tidak boleh kosong');
      return false;
    }

    return true;
  }

  void _handleError(dynamic e) {
    final errorMessage = e.toString();

    if (errorMessage.contains('Koneksi timeout')) {
      _showError('Koneksi timeout. Periksa internet Anda.');
    } else if (errorMessage.contains('Tidak ada koneksi internet')) {
      _showError('Tidak ada koneksi internet.');
    } else if (errorMessage.contains('Unauthorized') ||
        errorMessage.contains('401')) {
      _showError('Email atau password salah');
    } else {
      _showError('Email atau password salah');
    }
  }

  void _clearForm() {
    email.value = '';
    password.value = '';
    isPasswordVisible.value = false;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}
