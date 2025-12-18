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

  late TextEditingController emailController;
  late TextEditingController passwordController;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.toggle();
  }

  Future<void> login() async {
    if (!_validateForm()) return;

    // Konfirmasi sebelum login
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Login'),
        content: Text(
            'Apakah Anda yakin ingin login dengan email ${emailController.text.trim()}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya, Login'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;

      final response = await apiService.post(
        AppConstants.loginEndpoint,
        {
          'email': emailController.text.trim(),
          'password': passwordController.text,
        },
      );

      if (response['status'] == 'success') {
        final token = response['data']['token'];
        final user = UserModel.fromJson(response['data']['user']);

        await authService.saveLoginData(token, user);

        _showSuccess('Login berhasil! Selamat datang, ${user.name}');

        // Delay sedikit agar notifikasi terbaca
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.DASHBOARD);
      } else {
        _showError(response['message'] ?? 'Login gagal');
      }
    } catch (e) {
      _showError('Email atau password salah');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (emailController.text.trim().isEmpty) {
      _showError('Email tidak boleh kosong');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      _showError('Format email tidak valid');
      return false;
    }

    if (passwordController.text.isEmpty) {
      _showError('Password tidak boleh kosong');
      return false;
    }

    return true;
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Berhasil',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
