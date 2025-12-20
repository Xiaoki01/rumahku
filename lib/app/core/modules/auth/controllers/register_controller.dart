import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';

class RegisterController extends GetxController {
  final apiService = Get.find<ApiService>();
  final authService = Get.find<AuthService>();

  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final password = ''.obs;
  final confirmPassword = ''.obs;

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedRole = 'pengguna'.obs;
  final isAdminMode = false.obs;

  final roles = [
    {'value': 'admin', 'label': 'Administrator'},
    {'value': 'pengguna', 'label': 'Pemilik Bangunan'},
    {'value': 'kepala_proyek', 'label': 'Kepala Proyek'},
    {'value': 'mandor', 'label': 'Mandor'},
  ];

  void updateName(String value) => name.value = value;
  void updateEmail(String value) => email.value = value;
  void updatePhone(String value) => phone.value = value;
  void updatePassword(String value) => password.value = value;
  void updateConfirmPassword(String value) => confirmPassword.value = value;

  @override
  void onInit() {
    super.onInit();
    isAdminMode.value = authService.isLoggedIn;

    selectedRole.value = 'pengguna';
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (!_validateForm()) return;

    final roleLabel = roles.firstWhere(
      (role) =>
          role['value'] ==
          (isAdminMode.value ? selectedRole.value : 'pengguna'),
      orElse: () => {'label': 'Pengguna'},
    )['label'];

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(isAdminMode.value
            ? 'Konfirmasi Tambah Akun'
            : 'Konfirmasi Registrasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isAdminMode.value
                ? 'Apakah Anda yakin ingin menambahkan akun dengan data berikut?'
                : 'Apakah Anda yakin ingin mendaftar dengan data berikut?'),
            const SizedBox(height: 16),
            _buildConfirmationRow('Nama', name.value.trim()),
            _buildConfirmationRow('Email', email.value.trim()),
            if (phone.value.trim().isNotEmpty)
              _buildConfirmationRow('Telepon', phone.value.trim()),
            if (isAdminMode.value)
              _buildConfirmationRow('Role', roleLabel.toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text(isAdminMode.value ? 'Ya, Tambahkan' : 'Ya, Daftar'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;

      final data = {
        'name': name.value.trim(),
        'email': email.value.trim(),
        'phone': phone.value.trim(),
        'password': password.value,
        'role': isAdminMode.value ? selectedRole.value : 'pengguna',
      };

      final endpoint = isAdminMode.value
          ? AppConstants.adminAddUserEndpoint
          : AppConstants.registerEndpoint;

      final response = await apiService.post(
        endpoint,
        data,
      );

      if (response['status'] == 'success') {
        _showSuccess(
          isAdminMode.value
              ? 'Akun ${name.value.trim()} berhasil ditambahkan'
              : 'Registrasi berhasil! Silakan login dengan akun Anda',
        );

        _clearForm();

        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate
        if (isAdminMode.value) {
          Get.back();
        } else {
          Get.back();
        }
      } else {
        throw Exception(response['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (name.value.trim().isEmpty) {
      _showError('Nama lengkap tidak boleh kosong');
      return false;
    }

    if (email.value.trim().isEmpty) {
      _showError('Email tidak boleh kosong');
      return false;
    }

    if (!GetUtils.isEmail(email.value.trim())) {
      _showError('Format email tidak valid');
      return false;
    }

    if (password.value.isEmpty) {
      _showError('Password tidak boleh kosong');
      return false;
    }

    if (password.value.length < 6) {
      _showError('Password minimal 6 karakter');
      return false;
    }

    if (password.value != confirmPassword.value) {
      _showError('Konfirmasi password tidak cocok');
      return false;
    }

    return true;
  }

  void _clearForm() {
    name.value = '';
    email.value = '';
    phone.value = '';
    password.value = '';
    confirmPassword.value = '';
    selectedRole.value = 'pengguna';
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
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
    super.onClose();
  }
}
