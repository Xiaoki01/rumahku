import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/models/user_model.dart';

class EditProfileController extends GetxController {
  final authService = Get.find<AuthService>();
  final apiService = Get.find<ApiService>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  final isLoading = false.obs;
  final user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = Get.arguments as UserModel?;
    if (user.value != null) {
      nameController.text = user.value!.name;
      emailController.text = user.value!.email;
      phoneController.text = user.value!.phone ?? '';
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nama tidak boleh kosong';
    }
    if (value.length < 3) {
      return 'Nama minimal 3 karakter';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Format email tidak valid';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length < 10 || value.length > 15) {
        return 'Nomor telepon harus 10-15 digit';
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        return 'Nomor telepon hanya boleh angka';
      }
    }
    return null;
  }

  Future<void> updateProfile() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Konfirmasi sebelum update profile
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Update Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Apakah Anda yakin ingin memperbarui profile dengan data berikut?'),
            const SizedBox(height: 16),
            _buildConfirmationRow('Nama', nameController.text.trim()),
            _buildConfirmationRow('Email', emailController.text.trim()),
            if (phoneController.text.trim().isNotEmpty)
              _buildConfirmationRow('Telepon', phoneController.text.trim()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Ya, Update'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    try {
      isLoading.value = true;

      final response = await apiService.post(
        '/profile/update',
        {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
        },
      );

      if (response['status'] == 'success') {
        // Update current user
        final updatedUser = UserModel.fromJson(response['data']);
        authService.updateCurrentUser(updatedUser);

        _showSuccess('Profile ${updatedUser.name} berhasil diperbarui');

        await Future.delayed(const Duration(milliseconds: 500));
        Get.back(result: true);
      } else {
        throw Exception(response['message'] ?? 'Gagal memperbarui profile');
      }
    } catch (e) {
      _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading.value = false;
    }
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
