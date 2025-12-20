import 'package:get/get.dart';
import 'app_routes.dart';

import '../core/modules/auth/views/login_view.dart';
import '../core/modules/auth/controllers/login_controller.dart';
import '../core/modules/auth/views/register_view.dart';
import '../core/modules/auth/controllers/register_controller.dart';

import '../core/modules/dashboard/views/dashboard_view.dart';
import '../core/modules/dashboard/controllers/dashboard_controller.dart';

import '../core/modules/profile/views/profile_view.dart';
import '../core/modules/profile/controllers/profile_controller.dart';
import '../core/modules/profile/views/edit_profile_view.dart';
import '../core/modules/profile/controllers/edit_profile_controller.dart';
import '../core/modules/profile/views/change_password_view.dart';
import '../core/modules/profile/controllers/change_password_controller.dart';

import '../core/modules/project/views/project_list_view.dart';
import '../core/modules/project/controllers/project_controller.dart';
import '../core/modules/project/views/project_detail_view.dart';
import '../core/modules/project/views/project_form_view.dart';

import '../core/modules/report/views/report_list_view.dart';
import '../core/modules/report/controllers/report_controller.dart';
import '../core/modules/report/views/report_detail_view.dart';
import '../core/modules/report/views/report_form_view.dart';

import '../core/modules/material/views/material_list_view.dart';
import '../core/modules/material/controllers/material_controller.dart';
import '../core/modules/material/views/material_detail_view.dart';
import '../core/modules/material/views/material_form_view.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController());
      }),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RegisterController());
      }),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => DashboardController());
      }),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ProfileController());
      }),
    ),
    GetPage(
      name: Routes.EDIT_PROFILE,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EditProfileController());
      }),
    ),
    GetPage(
      name: Routes.CHANGE_PASSWORD,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChangePasswordController());
      }),
    ),
    GetPage(
      name: Routes.PROJECT_LIST,
      page: () => const ProjectListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProjectController>(() => ProjectController());
      }),
    ),
    GetPage(
      name: Routes.PROJECT_DETAIL,
      page: () => const ProjectDetailView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProjectController>()) {
          Get.lazyPut<ProjectController>(() => ProjectController());
        }
      }),
    ),
    GetPage(
      name: Routes.PROJECT_CREATE,
      page: () => const ProjectFormView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProjectController>()) {
          Get.lazyPut<ProjectController>(() => ProjectController());
        }
      }),
    ),
    GetPage(
      name: Routes.PROJECT_EDIT,
      page: () => const ProjectFormView(isEdit: true),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ProjectController>()) {
          Get.lazyPut<ProjectController>(() => ProjectController());
        }
      }),
    ),
    GetPage(
      name: Routes.REPORT_LIST,
      page: () => const ReportListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ReportController>(() => ReportController());
      }),
    ),
    GetPage(
      name: Routes.REPORT_DETAIL,
      page: () => const ReportDetailView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ReportController>()) {
          Get.lazyPut<ReportController>(() => ReportController());
        }
      }),
    ),
    GetPage(
      name: Routes.REPORT_CREATE,
      page: () => const ReportFormView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<ReportController>()) {
          Get.lazyPut<ReportController>(() => ReportController());
        }
      }),
    ),
    GetPage(
      name: Routes.MATERIAL_LIST,
      page: () => const MaterialListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<MaterialController>(() => MaterialController());
      }),
    ),
    GetPage(
      name: Routes.MATERIAL_DETAIL,
      page: () => const MaterialDetailView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MaterialController>()) {
          Get.lazyPut<MaterialController>(() => MaterialController());
        }
      }),
    ),
    GetPage(
      name: Routes.MATERIAL_CREATE,
      page: () => const MaterialFormView(),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<MaterialController>()) {
          Get.lazyPut<MaterialController>(() => MaterialController());
        }
      }),
    ),
  ];
}
