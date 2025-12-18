import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/material_model.dart';
import '../../../../data/models/project_model.dart';

class MaterialController extends GetxController {
  final apiService = Get.find<ApiService>();
  final authService = Get.find<AuthService>();

  final isLoading = false.obs;
  final materials = <MaterialModel>[].obs;
  final selectedMaterial = Rx<MaterialModel?>(null);

  // Form Controllers
  final materialNameController = TextEditingController();
  final quantityController = TextEditingController();
  final unitController = TextEditingController();
  final descriptionController = TextEditingController();
  final selectedProject = Rx<ProjectModel?>(null);

  @override
  void onClose() {
    materialNameController.dispose();
    quantityController.dispose();
    unitController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Fetch materials by project dengan filter role
  Future<void> fetchMaterialsByProject(String projectId) async {
    try {
      isLoading.value = true;

      final response = await apiService.get(
        '${AppConstants.materialsEndpoint}/project/$projectId',
      );

      if (response['status'] == 'success') {
        final allMaterials = (response['data'] as List)
            .map((json) => MaterialModel.fromJson(json))
            .toList();

        // Filter berdasarkan role jika perlu
        materials.value = _filterMaterialsByRole(allMaterials);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  List<MaterialModel> _filterMaterialsByRole(List<MaterialModel> allMaterials) {
    final user = authService.currentUser.value;
    if (user == null) return [];

    // Admin & Kepala Proyek: Lihat semua material
    if (authService.isAdmin || authService.isKepalaProyek) {
      return allMaterials;
    }

    // Mandor: Lihat material yang dia request
    if (authService.isMandor) {
      return allMaterials.where((m) => m.mandorId == user.id).toList();
    }

    // Pengguna: Lihat semua material dari project mereka (read-only)
    if (authService.isPengguna) {
      return allMaterials;
    }

    return [];
  }

  // Get material detail
  Future<void> getMaterialDetail(String id) async {
    try {
      isLoading.value = true;

      final response = await apiService.get(
        '${AppConstants.materialsEndpoint}/$id',
      );

      if (response['status'] == 'success') {
        selectedMaterial.value = MaterialModel.fromJson(response['data']);
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Create material request (Mandor only)
  Future<void> createMaterialRequest() async {
    if (!authService.isMandor) {
      _showError('Hanya mandor yang dapat request material');
      return;
    }

    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      final response = await apiService.post(
        AppConstants.materialsEndpoint,
        {
          'project_id': selectedProject.value!.id,
          'material_name': materialNameController.text.trim(),
          'quantity': double.parse(quantityController.text),
          'unit': unitController.text.trim(),
          'description': descriptionController.text.trim(),
        },
      );

      if (response['status'] == 'success') {
        _showSuccess('Request material berhasil dibuat');

        if (selectedProject.value != null) {
          await fetchMaterialsByProject(selectedProject.value!.id);
        }

        Get.back();
        _clearForm();
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Approve material (Kepala Proyek / Admin ONLY)
  Future<void> approveMaterial(String id) async {
    if (!authService.isKepalaProyek && !authService.isAdmin) {
      _showError(
          'Hanya kepala proyek atau admin yang dapat menyetujui material');
      return;
    }

    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Setujui request material ini?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Setujui'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;

        final response = await apiService.put(
          '${AppConstants.materialsEndpoint}/$id/approve',
          {},
        );

        if (response['status'] == 'success') {
          _showSuccess('Material berhasil disetujui');

          await getMaterialDetail(id);

          // Refresh list if project selected
          if (selectedProject.value != null) {
            await fetchMaterialsByProject(selectedProject.value!.id);
          }
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // Reject material (Kepala Proyek / Admin ONLY)
  Future<void> rejectMaterial(String id) async {
    if (!authService.isKepalaProyek && !authService.isAdmin) {
      _showError('Hanya kepala proyek atau admin yang dapat menolak material');
      return;
    }

    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Tolak request material ini?'),
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
              child: const Text('Tolak'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;

        final response = await apiService.put(
          '${AppConstants.materialsEndpoint}/$id/reject',
          {},
        );

        if (response['status'] == 'success') {
          _showWarning('Material ditolak');

          await getMaterialDetail(id);

          // Refresh list if project selected
          if (selectedProject.value != null) {
            await fetchMaterialsByProject(selectedProject.value!.id);
          }
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    if (selectedProject.value == null) {
      _showError('Pilih project terlebih dahulu');
      return false;
    }

    if (materialNameController.text.trim().isEmpty) {
      _showError('Nama material tidak boleh kosong');
      return false;
    }

    if (quantityController.text.isEmpty) {
      _showError('Jumlah tidak boleh kosong');
      return false;
    }

    try {
      double.parse(quantityController.text);
    } catch (e) {
      _showError('Jumlah harus berupa angka');
      return false;
    }

    if (unitController.text.trim().isEmpty) {
      _showError('Satuan tidak boleh kosong');
      return false;
    }

    return true;
  }

  void _clearForm() {
    materialNameController.clear();
    quantityController.clear();
    unitController.clear();
    descriptionController.clear();
    selectedProject.value = null;
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
  bool get canApproveReject =>
      authService.isAdmin || authService.isKepalaProyek;

  bool get canCreateRequest => authService.isMandor;

  bool get isReadOnly => authService.isPengguna;
}
