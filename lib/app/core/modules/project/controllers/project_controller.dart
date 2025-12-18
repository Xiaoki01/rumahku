import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/project_model.dart';

class ProjectController extends GetxController {
  final apiService = Get.find<ApiService>();
  final authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final projects = <ProjectModel>[].obs;
  final selectedProject = Rx<ProjectModel?>(null);

  @override
  void onInit() {
    super.onInit();
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      isLoading.value = true;

      final response = await apiService.get(AppConstants.projectsEndpoint);

      if (response['status'] == 'success') {
        final allProjects = (response['data'] as List)
            .map((json) => ProjectModel.fromJson(json))
            .toList();

        // Filter berdasarkan role
        projects.value = _filterProjectsByRole(allProjects);
      }
    } catch (e) {
      _showError('Gagal memuat data project: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  List<ProjectModel> _filterProjectsByRole(List<ProjectModel> allProjects) {
    final user = authService.currentUser.value;
    if (user == null) return [];

    // Admin: Lihat semua project
    if (authService.isAdmin) {
      return allProjects;
    }

    // Kepala Proyek: Lihat project yang dia tangani
    if (authService.isKepalaProyek) {
      return allProjects.where((p) => p.kepalaProyekId == user.id).toList();
    }

    // Mandor: Lihat project yang dia tangani
    if (authService.isMandor) {
      return allProjects.where((p) => p.mandorId == user.id).toList();
    }

    // Pengguna: Lihat project milik sendiri
    if (authService.isPengguna) {
      return allProjects.where((p) => p.userId == user.id).toList();
    }

    return [];
  }

  Future<void> getProjectDetail(String id) async {
    try {
      isLoading.value = true;

      final response =
          await apiService.get('${AppConstants.projectsEndpoint}/$id');

      if (response['status'] == 'success') {
        selectedProject.value = ProjectModel.fromJson(response['data']);
      }
    } catch (e) {
      _showError('Gagal memuat detail project: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProject(Map<String, dynamic> data) async {
    // Hanya Admin yang bisa create project
    if (!authService.isAdmin) {
      _showError('Anda tidak memiliki akses untuk membuat project');
      return;
    }

    try {
      isLoading.value = true;

      final response =
          await apiService.post(AppConstants.projectsEndpoint, data);

      if (response['status'] == 'success') {
        final projectName = data['name'] ?? 'Project';
        _showSuccess('Project "$projectName" berhasil dibuat');

        await fetchProjects();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      }
    } catch (e) {
      _showError('Gagal membuat project: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProject(String id, Map<String, dynamic> data) async {
    // Hanya Admin dan Kepala Proyek yang bisa edit
    if (!authService.isAdmin && !authService.isKepalaProyek) {
      _showError('Anda tidak memiliki akses untuk edit project');
      return;
    }

    try {
      isLoading.value = true;

      final response =
          await apiService.put('${AppConstants.projectsEndpoint}/$id', data);

      if (response['status'] == 'success') {
        final projectName =
            data['name'] ?? selectedProject.value?.name ?? 'Project';
        _showSuccess('Project "$projectName" berhasil diupdate');

        await fetchProjects();
        await Future.delayed(const Duration(milliseconds: 500));
        Get.back();
      }
    } catch (e) {
      _showError('Gagal update project: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProject(String id) async {
    // Hanya Admin yang bisa delete
    if (!authService.isAdmin) {
      _showError('Anda tidak memiliki akses untuk menghapus project');
      return;
    }

    try {
      final projectName = selectedProject.value?.name ?? 'project ini';

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
              'Yakin ingin menghapus project "$projectName"?\n\nData project ini akan dihapus permanen.'),
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
              child: const Text('Ya, Hapus'),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (confirmed == true) {
        isLoading.value = true;

        final response =
            await apiService.delete('${AppConstants.projectsEndpoint}/$id');

        if (response['status'] == 'success') {
          _showWarning('Project "$projectName" berhasil dihapus');

          await fetchProjects();
          await Future.delayed(const Duration(milliseconds: 500));
          Get.back();
        }
      }
    } catch (e) {
      _showError('Gagal menghapus project: ${e.toString()}');
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

  void _showWarning(String message) {
    Get.snackbar(
      'Informasi',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.orange[600],
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info, color: Colors.white),
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

  // Check permissions
  bool get canCreate => authService.isAdmin;

  bool get canEdit => authService.isAdmin || authService.isKepalaProyek;

  bool get canDelete => authService.isAdmin;
}
