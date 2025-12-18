import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/services/api_service.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/report_model.dart';
import '../../../../data/models/project_model.dart';

class ReportController extends GetxController {
  final apiService = Get.find<ApiService>();
  final authService = Get.find<AuthService>();
  final ImagePicker _picker = ImagePicker();

  final isLoading = false.obs;
  final reports = <ReportModel>[].obs;
  final selectedReport = Rx<ReportModel?>(null);
  final selectedImage = Rx<File?>(null);

  // Form Controllers
  final dateController = TextEditingController();
  final progressController = TextEditingController();
  final descriptionController = TextEditingController();
  final kendalaController = TextEditingController();
  final jumlahTenagaKerjaController = TextEditingController();
  final selectedProject = Rx<ProjectModel?>(null);

  @override
  void onClose() {
    dateController.dispose();
    progressController.dispose();
    descriptionController.dispose();
    kendalaController.dispose();
    jumlahTenagaKerjaController.dispose();
    super.onClose();
  }

  // Pick image from gallery or camera - FIXED
  Future<void> pickImage() async {
    try {
      // Show dialog to choose source
      final ImageSource? source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: const Text('Pilih Sumber Foto'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library, color: Colors.blue[700]),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Pilih dari galeri foto'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: Colors.purple[700]),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Ambil foto baru'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Batal'),
            ),
          ],
        ),
      );

      if (source == null) return;

      // Pick image with proper error handling
      try {
        final XFile? pickedFile = await _picker.pickImage(
          source: source,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          selectedImage.value = File(pickedFile.path);

          Get.snackbar(
            'Berhasil',
            'Foto berhasil dipilih',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(16),
          );
        } else {
          Get.snackbar(
            'Dibatalkan',
            'Pemilihan foto dibatalkan',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
            margin: const EdgeInsets.all(16),
          );
        }
      } catch (e) {
        Get.snackbar(
          'Error',
          'Gagal mengambil foto: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // Remove selected image with confirmation
  Future<void> removeImage() async {
    if (selectedImage.value == null) return;

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Hapus Foto'),
        content: const Text('Apakah Anda yakin ingin menghapus foto ini?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
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
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      selectedImage.value = null;
      Get.snackbar(
        'Berhasil',
        'Foto berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // Fetch reports by project dengan filter role
  Future<void> fetchReportsByProject(String projectId) async {
    try {
      isLoading.value = true;

      final response = await apiService.get(
        '${AppConstants.reportsEndpoint}/project/$projectId',
      );

      if (response['status'] == 'success') {
        final allReports = (response['data'] as List)
            .map((json) => ReportModel.fromJson(json))
            .toList();

        reports.value = _filterReportsByRole(allReports);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat laporan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<ReportModel> _filterReportsByRole(List<ReportModel> allReports) {
    final user = authService.currentUser.value;
    if (user == null) return [];

    if (authService.isAdmin || authService.isKepalaProyek) {
      return allReports;
    }

    if (authService.isMandor) {
      return allReports.where((r) => r.mandorId == user.id).toList();
    }

    if (authService.isPengguna) {
      return allReports;
    }

    return [];
  }

  // Get report detail
  Future<void> getReportDetail(String id) async {
    try {
      isLoading.value = true;

      final response = await apiService.get(
        '${AppConstants.reportsEndpoint}/$id',
      );

      if (response['status'] == 'success') {
        selectedReport.value = ReportModel.fromJson(response['data']);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat detail laporan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Create report (Mandor only) - WITH PHOTO SUPPORT & CONFIRMATION
  Future<void> createReport() async {
    if (!authService.isMandor) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya mandor yang dapat membuat laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.block, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    if (!_validateForm()) return;

    // Konfirmasi sebelum submit
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Laporan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin mengirim laporan ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildConfirmationRow(
                      'Project', selectedProject.value?.name ?? '-'),
                  _buildConfirmationRow('Tanggal', dateController.text),
                  _buildConfirmationRow(
                      'Progress', '${progressController.text}%'),
                  _buildConfirmationRow('Tenaga Kerja',
                      '${jumlahTenagaKerjaController.text} orang'),
                  if (selectedImage.value != null)
                    _buildConfirmationRow('Foto', 'Ada'),
                ],
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Kirim Laporan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      isLoading.value = true;

      // Prepare data
      final data = {
        'project_id': selectedProject.value!.id,
        'date': dateController.text,
        'progress': double.parse(progressController.text).toString(),
        'description': descriptionController.text.trim(),
        'kendala': kendalaController.text.trim().isEmpty
            ? ''
            : kendalaController.text.trim(),
        'jumlah_tenaga_kerja':
            int.parse(jumlahTenagaKerjaController.text).toString(),
      };

      // Gunakan postMultipart jika ada foto, atau post biasa jika tidak ada
      final response = selectedImage.value != null
          ? await apiService.postMultipart(
              AppConstants.reportsEndpoint,
              data,
              file: selectedImage.value!,
              fileKey: 'photo',
            )
          : await apiService.post(
              AppConstants.reportsEndpoint,
              data,
            );

      if (response['status'] == 'success') {
        Get.snackbar(
          'Berhasil',
          selectedImage.value != null
              ? 'Laporan dan foto berhasil dikirim'
              : 'Laporan berhasil dibuat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );

        if (selectedProject.value != null) {
          await fetchReportsByProject(selectedProject.value!.id);
        }

        Get.back();
        _clearForm();
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim laporan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Helper widget for confirmation dialog
  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Verify report (Kepala Proyek only) with enhanced confirmation
  Future<void> verifyReport(String id) async {
    if (!authService.isKepalaProyek) {
      Get.snackbar(
        'Akses Ditolak',
        'Hanya kepala proyek yang dapat memverifikasi laporan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.block, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: Row(
            children: [
              Icon(Icons.verified, color: Colors.green[700]),
              const SizedBox(width: 8),
              const Text('Verifikasi Laporan'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin memverifikasi laporan ini? '
            'Tindakan ini menandakan bahwa laporan telah diperiksa dan disetujui.',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
              child: const Text('Verifikasi'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;

        final response = await apiService.put(
          '${AppConstants.reportsEndpoint}/$id/verify',
          {},
        );

        if (response['status'] == 'success') {
          Get.snackbar(
            'Berhasil',
            'Laporan berhasil diverifikasi',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
            icon: const Icon(Icons.check_circle, color: Colors.white),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );

          await getReportDetail(id);

          if (selectedProject.value != null) {
            await fetchReportsByProject(selectedProject.value!.id);
          }
        }
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memverifikasi laporan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error_outline, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Cancel form with confirmation
  Future<bool> cancelForm() async {
    // Check if form has data
    final hasData = dateController.text.isNotEmpty ||
        progressController.text.isNotEmpty ||
        descriptionController.text.isNotEmpty ||
        kendalaController.text.isNotEmpty ||
        jumlahTenagaKerjaController.text.isNotEmpty ||
        selectedImage.value != null;

    if (!hasData) {
      return true; // No data, can close directly
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Batalkan Laporan'),
        content: const Text(
          'Anda memiliki data yang belum disimpan. '
          'Apakah Anda yakin ingin membatalkan?',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _clearForm();
      return true;
    }

    return false;
  }

  // Get reports count by status
  int get totalReports => reports.length;

  int get pendingReports =>
      reports.where((r) => r.status == AppConstants.reportMenunggu).length;

  int get verifiedReports =>
      reports.where((r) => r.status == AppConstants.reportDiverifikasi).length;

  // Calculate average progress
  double get averageProgress {
    if (reports.isEmpty) return 0.0;
    final total = reports.fold<double>(
      0.0,
      (sum, report) => sum + double.parse(report.progress),
    );
    return total / reports.length;
  }

  bool _validateForm() {
    if (selectedProject.value == null) {
      Get.snackbar(
        'Validasi Gagal',
        'Pilih project terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    if (dateController.text.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Tanggal tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    if (progressController.text.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Progress tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    try {
      final progress = double.parse(progressController.text);
      if (progress < 0 || progress > 100) {
        Get.snackbar(
          'Validasi Gagal',
          'Progress harus antara 0-100',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber, color: Colors.white),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Validasi Gagal',
        'Progress harus berupa angka',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Deskripsi tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    if (jumlahTenagaKerjaController.text.isEmpty) {
      Get.snackbar(
        'Validasi Gagal',
        'Jumlah tenaga kerja tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    try {
      final workers = int.parse(jumlahTenagaKerjaController.text);
      if (workers < 0) {
        Get.snackbar(
          'Validasi Gagal',
          'Jumlah tenaga kerja tidak boleh negatif',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          icon: const Icon(Icons.warning_amber, color: Colors.white),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Validasi Gagal',
        'Jumlah tenaga kerja harus berupa angka',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: const Icon(Icons.warning_amber, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return false;
    }

    return true;
  }

  void _clearForm() {
    dateController.clear();
    progressController.clear();
    descriptionController.clear();
    kendalaController.clear();
    jumlahTenagaKerjaController.clear();
    selectedProject.value = null;
    selectedImage.value = null;
  }

  // Check permissions
  bool get canVerify => authService.isKepalaProyek;

  bool get canCreateReport => authService.isMandor;

  bool get isReadOnly => authService.isPengguna;
}
