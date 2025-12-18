class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://10.0.2.2/rumahku-backend/public/api';
  static const String imageBaseUrl = 'http://10.0.2.2/rumahku-backend/public';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String profileEndpoint = '/profile';
  static const String projectsEndpoint = '/projects';
  static const String reportsEndpoint = '/reports';
  static const String materialsEndpoint = '/materials';

  // User Roles
  static const String roleAdmin = 'admin';
  static const String rolePengguna = 'pengguna';
  static const String roleKepalaProyek = 'kepala_proyek';
  static const String roleMandor = 'mandor';

  // Project Status
  static const String statusPlanning = 'planning';
  static const String statusOngoing = 'ongoing';
  static const String statusCompleted = 'completed';
  static const String statusSuspended = 'suspended';

  // Report Status
  static const String reportMenunggu = 'menunggu';
  static const String reportDiverifikasi = 'diverifikasi';

  // Material Status
  static const String materialPending = 'pending';
  static const String materialApproved = 'approved';
  static const String materialRejected = 'rejected';
  static const String materialDelivered = 'delivered';

  /// Helper method untuk memperbaiki URL Gambar
  /// Memastikan IP backend diganti ke IP emulator tanpa menduplikasi folder project
  static String fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Debug log untuk memantau proses di terminal
    print('🔧 Original URL: $url');

    // 1. Jika URL dari backend sudah lengkap (dimulai dengan http://192.168.1.100)
    // Kita hanya mengganti IP-nya saja agar path '/rumahku-backend/public/' tidak dobel
    if (url.startsWith('http://192.168.1.100')) {
      final fixed = url.replaceFirst('http://192.168.1.100', 'http://10.0.2.2');
      print('✅ Fixed URL (IP Replaced): $fixed');
      return fixed;
    }

    // 2. Jika sudah benar menggunakan 10.0.2.2, biarkan saja
    if (url.startsWith('http://10.0.2.2')) {
      return url;
    }

    // 3. Jika hanya berupa nama file (misal: "123.jpg")
    // Tambahkan base URL dan path folder reports secara manual
    if (!url.startsWith('http')) {
      final cleanPath = url.startsWith('/') ? url.substring(1) : url;
      final fixed = '$imageBaseUrl/uploads/reports/$cleanPath';
      print('✅ Fixed URL (Relative to Reports): $fixed');
      return fixed;
    }

    return url;
  }
}
