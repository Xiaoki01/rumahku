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
    ever(authService.currentUser, (_) => loadDashboardData());
  }

  @override
  void onReady() {
    super.onReady();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    if (authService.token == null || authService.token!.isEmpty) {
      print('No token found, skipping dashboard load');
      return;
    }

    try {
      isLoading.value = true;
      print('Fetching dashboard data...');

      final response = await apiService.get(AppConstants.projectsEndpoint);

      if (response['status'] == 'success') {
        final List rawData = response['data'];
        final allProjects =
            rawData.map((json) => ProjectModel.fromJson(json)).toList();
        projects.assignAll(_filterProjectsByRole(allProjects));

        print('✅ Dashboard data synchronized: ${projects.length} projects');
      }
    } catch (e) {
      print('Error loading dashboard: $e');
      if (!e.toString().contains('Unauthorized')) {
        Get.snackbar('Error', 'Gagal memperbarui dashboard: ${e.toString()}');
      }
    } finally {
      isLoading.value = false;
    }
  }

  List<ProjectModel> _filterProjectsByRole(List<ProjectModel> allProjects) {
    final user = authService.currentUser.value;
    if (user == null) return [];

    if (authService.isAdmin) return allProjects;

    if (authService.isKepalaProyek) {
      return allProjects.where((p) => p.kepalaProyekId == user.id).toList();
    }

    if (authService.isMandor) {
      return allProjects.where((p) => p.mandorId == user.id).toList();
    }

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
