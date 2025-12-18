import '../../../app/core/constants/app_constants.dart';

class ReportModel {
  final String id;
  final String projectId;
  final String mandorId;
  final String date;
  final String progress;
  final String description;
  final String? kendala;
  final int jumlahTenagaKerja;
  final String? photo;
  final String? photoUrl;
  final String status;
  final String? verifiedBy;
  final String? verifiedAt;
  final String? createdAt;
  final String? updatedAt;

  final String? projectName;
  final String? mandorName;
  final String? verifiedByName;

  ReportModel({
    required this.id,
    required this.projectId,
    required this.mandorId,
    required this.date,
    required this.progress,
    required this.description,
    this.kendala,
    required this.jumlahTenagaKerja,
    this.photo,
    this.photoUrl,
    required this.status,
    this.verifiedBy,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
    this.projectName,
    this.mandorName,
    this.verifiedByName,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // 🆕 Debug log untuk lihat data mentah
    print('📦 Raw JSON photo: ${json['photo']}');
    print('📦 Raw JSON photo_url: ${json['photo_url']}');

    // 🆕 Fix photo URL dari backend
    String? fixedPhotoUrl;

    // Prioritas: gunakan photo_url dulu jika ada
    if (json['photo_url'] != null && json['photo_url'].toString().isNotEmpty) {
      fixedPhotoUrl = AppConstants.fixImageUrl(json['photo_url']);
    }
    // Fallback: jika hanya ada photo (filename), build full URL
    else if (json['photo'] != null && json['photo'].toString().isNotEmpty) {
      final photoPath = 'uploads/reports/${json['photo']}';
      fixedPhotoUrl = AppConstants.fixImageUrl(photoPath);
    }

    print('✅ Final photo URL: $fixedPhotoUrl');

    return ReportModel(
      id: json['id'].toString(),
      projectId: json['project_id'].toString(),
      mandorId: json['mandor_id'].toString(),
      date: json['date'],
      progress: json['progress'].toString(),
      description: json['description'],
      kendala: json['kendala'],
      jumlahTenagaKerja:
          int.tryParse(json['jumlah_tenaga_kerja'].toString()) ?? 0,
      photo: json['photo'],
      photoUrl: fixedPhotoUrl,
      status: json['status'],
      verifiedBy: json['verified_by']?.toString(),
      verifiedAt: json['verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      projectName: json['project_name'],
      mandorName: json['mandor_name'],
      verifiedByName: json['verified_by_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'date': date,
      'progress': progress,
      'description': description,
      'kendala': kendala,
      'jumlah_tenaga_kerja': jumlahTenagaKerja,
      'photo': photo,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'menunggu':
        return 'Menunggu Verifikasi';
      case 'diverifikasi':
        return 'Diverifikasi';
      default:
        return status;
    }
  }

  // 🆕 Getter untuk image URL yang sudah fix
  String get imageUrl => photoUrl ?? '';

  // 🆕 Check apakah ada foto
  bool get hasPhoto => imageUrl.isNotEmpty;
}
