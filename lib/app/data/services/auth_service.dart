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

  // Check if user is logged in
  bool get isLoggedIn => _storage.read(AppConstants.tokenKey) != null;

  // Get stored token
  String? get token => _storage.read(AppConstants.tokenKey);

  // Get user role
  String? get userRole => currentUser.value?.role;

  // Load user from storage
  void _loadUserFromStorage() {
    final userData = _storage.read(AppConstants.userKey);
    if (userData != null) {
      currentUser.value = UserModel.fromJson(jsonDecode(userData));
    }
  }

  // Save login data
  Future<void> saveLoginData(String token, UserModel user) async {
    await _storage.write(AppConstants.tokenKey, token);
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
    currentUser.value = user;
  }

  // Update current user (after edit profile)
  Future<void> updateCurrentUser(UserModel user) async {
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
    currentUser.value = user;
  }

  // Logout
  Future<void> logout() async {
    await _storage.remove(AppConstants.tokenKey);
    await _storage.remove(AppConstants.userKey);
    currentUser.value = null;
    Get.offAllNamed(Routes.LOGIN);
  }

  // Check if user has role
  bool hasRole(String role) {
    return currentUser.value?.role == role;
  }

  // Check if user is admin
  bool get isAdmin => hasRole(AppConstants.roleAdmin);

  // Check if user is pengguna
  bool get isPengguna => hasRole(AppConstants.rolePengguna);

  // Check if user is kepala proyek
  bool get isKepalaProyek => hasRole(AppConstants.roleKepalaProyek);

  // Check if user is mandor
  bool get isMandor => hasRole(AppConstants.roleMandor);
}
