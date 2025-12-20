import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../project/controllers/project_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ReportController>(ReportController());

    if (!Get.isRegistered<ProjectController>()) {
      Get.put<ProjectController>(ProjectController());
    }
  }
}
