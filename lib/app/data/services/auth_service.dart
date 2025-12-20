import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../../routes/app_routes.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadUserFromStorage();
  }

  bool get isLoggedIn => _storage.read(AppConstants.tokenKey) != null;

  String? get token => _storage.read(AppConstants.tokenKey);

  String? get userRole => currentUser.value?.role;

  void _loadUserFromStorage() {
    final userData = _storage.read(AppConstants.userKey);
    if (userData != null) {
      currentUser.value = UserModel.fromJson(jsonDecode(userData));
    }
  }

  Future<void> saveLoginData(String token, UserModel user) async {
    await _storage.write(AppConstants.tokenKey, token);
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
    currentUser.value = user;
  }

  Future<void> updateCurrentUser(UserModel user) async {
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
    currentUser.value = user;
  }

  //logout
  Future<void> logout() async {
    await _storage.remove(AppConstants.tokenKey);
    await _storage.remove(AppConstants.userKey);
    currentUser.value = null;
    Get.offAllNamed(Routes.LOGIN);
  }

  bool hasRole(String role) {
    return currentUser.value?.role == role;
  }

  bool get isAdmin => hasRole(AppConstants.roleAdmin);

  bool get isPengguna => hasRole(AppConstants.rolePengguna);

  bool get isKepalaProyek => hasRole(AppConstants.roleKepalaProyek);

  bool get isMandor => hasRole(AppConstants.roleMandor);
}
