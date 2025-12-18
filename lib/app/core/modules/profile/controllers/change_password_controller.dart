import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';

class ChangePasswordController extends GetxController {
  final apiService = Get.find<ApiService>();

  final formKey = GlobalKey<FormState>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isLoading = false.obs;
  final obscureOldPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  void onClose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleOldPasswordVisibility() {
    obscureOldPassword.value = !obscureOldPassword.value;
  }

  void toggleNewPasswordVisibility() {
    obscureNewPassword.value = !obscureNewPassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  String? validateOldPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password lama tidak boleh kosong';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password baru tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    if (value == oldPasswordController.text) {
      return 'Password baru harus berbeda dengan password lama';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != newPasswordController.text) {
      return 'Konfirmasi password tidak cocok';
    }
    return null;
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Konfirmasi sebelum mengubah password
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Ubah Password'),
        content: const Text(
            'Apakah Anda yakin ingin mengubah password?\n\nPastikan Anda mengingat password baru Anda.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya, Ubah Password'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;

      final response = await apiService.post(
        '/profile/change-password',
        {
          'old_password': oldPasswordController.text,
          'new_password': newPasswordController.text,
          'confirm_password': confirmPasswordController.text,
        },
      );

      if (response['status'] == 'success') {
        _showSuccess(
            'Password berhasil diubah. Gunakan password baru untuk login selanjutnya');

        // Clear form
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      } else {
        throw Exception(response['message'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
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
