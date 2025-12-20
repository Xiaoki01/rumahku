import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/user_model.dart';
import 'package:flutter/material.dart';

class ProfileController extends GetxController {
  final authService = Get.find<AuthService>();
  final apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      isLoading.value = true;

      final response = await apiService.get(AppConstants.profileEndpoint);

      if (response['status'] == 'success') {
        user.value = UserModel.fromJson(response['data']);
      }
    } catch (e) {
      user.value = authService.currentUser.value;
      _showError('Gagal memuat profile, menampilkan data tersimpan');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final userName = user.value?.name ?? 'Pengguna';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Logout'),
        content:
            Text('$userName, apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Ya, Logout'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed == true) {
      await authService.logout();
      _showSuccess('Berhasil logout. Sampai jumpa lagi!');
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
