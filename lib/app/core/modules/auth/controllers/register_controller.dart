import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';

class RegisterController extends GetxController {
  final apiService = Get.find<ApiService>();
  final authService = Get.find<AuthService>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final selectedRole = 'pengguna'.obs; // Default role untuk public user
  final isAdminMode = false.obs;

  final roles = [
    {'value': 'admin', 'label': 'Administrator'},
    {'value': 'pengguna', 'label': 'Pemilik Bangunan'},
    {'value': 'kepala_proyek', 'label': 'Kepala Proyek'},
    {'value': 'mandor', 'label': 'Mandor'},
  ];

  @override
  void onInit() {
    super.onInit();
    // Cek apakah dipanggil dari admin atau public
    isAdminMode.value = authService.isLoggedIn;

    // Jika admin mode, default role tetap pengguna
    // Jika public mode, force role ke pengguna
    selectedRole.value = 'pengguna';
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    // Validasi
    if (!_validateForm()) return;

    // Konfirmasi sebelum register
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
            _buildConfirmationRow('Nama', nameController.text.trim()),
            _buildConfirmationRow('Email', emailController.text.trim()),
            if (phoneController.text.trim().isNotEmpty)
              _buildConfirmationRow('Telepon', phoneController.text.trim()),
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
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
        'password': passwordController.text,
        'role': isAdminMode.value
            ? selectedRole.value // Admin bisa pilih role
            : 'pengguna', // Public user fixed ke "pengguna"
      };

      final response = await apiService.post(
        AppConstants.registerEndpoint,
        data,
      );

      if (response['status'] == 'success') {
        _showSuccess(
          isAdminMode.value
              ? 'Akun ${nameController.text.trim()} berhasil ditambahkan'
              : 'Registrasi berhasil! Silakan login dengan akun Anda',
        );

        // Clear form
        nameController.clear();
        emailController.clear();
        phoneController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        selectedRole.value = 'pengguna';

        // Delay sedikit agar notifikasi terbaca
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate
        if (isAdminMode.value) {
          // Jika admin mode, kembali ke profile
          Get.back();
        } else {
          // Jika public mode, kembali ke login
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
    if (nameController.text.trim().isEmpty) {
      _showError('Nama lengkap tidak boleh kosong');
      return false;
    }

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

    if (passwordController.text.length < 6) {
      _showError('Password minimal 6 karakter');
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      _showError('Konfirmasi password tidak cocok');
      return false;
    }

    return true;
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
}
