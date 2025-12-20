import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(
      LoginController(),
      tag: 'login',
    );

    Get.put<RegisterController>(
      RegisterController(),
      tag: 'register',
    );
  }
}
