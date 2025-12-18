import 'package:get/get.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/project_model.dart';

class DashboardController extends GetxController {
  final authService = Get.find<AuthService>();
  final apiService = Get.find<ApiService>();

  final isLoading = false.obs;
  final projects = <ProjectModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Load projects berdasarkan role
      final projectsResponse =
          await apiService.get(AppConstants.projectsEndpoint);

      if (projectsResponse['status'] == 'success') {
        final allProjects = (projectsResponse['data'] as List)
            .map((json) => ProjectModel.fromJson(json))
            .toList();

        // Filter projects berdasarkan role
        projects.value = _filterProjectsByRole(allProjects);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
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

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  int get totalProjects => projects.length;

  int get activeProjects => projects.where((p) => p.status == 'ongoing').length;

  int get completedProjects =>
      projects.where((p) => p.status == 'completed').length;

  int get planningProjects =>
      projects.where((p) => p.status == 'planning').length;
}
