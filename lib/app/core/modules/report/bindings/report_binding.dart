import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../project/controllers/project_controller.dart';

class ReportBinding extends Bindings {
  @override
  void dependencies() {
    // Put ReportController (bukan lazyPut agar langsung initialized)
    Get.put<ReportController>(ReportController());

    // Pastikan ProjectController juga initialized untuk dropdown
    if (!Get.isRegistered<ProjectController>()) {
      Get.put<ProjectController>(ProjectController());
    }
  }
}
