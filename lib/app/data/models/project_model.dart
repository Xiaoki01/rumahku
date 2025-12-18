class ProjectModel {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final String startDate;
  final String? endDate;
  final String? budget;
  final String status;
  final String userId;
  final String kepalaProyekId;
  final String mandorId;
  final String? createdAt;
  final String? updatedAt;

  // Additional fields from JOIN
  final String? ownerName;
  final String? ownerEmail;
  final String? ownerPhone;
  final String? kepalaProyekName;
  final String? kepalaProyekEmail;
  final String? kepalaProyekPhone;
  final String? mandorName;
  final String? mandorEmail;
  final String? mandorPhone;

  ProjectModel({
    required this.id,
    required this.name,
    this.description,
    this.location,
    required this.startDate,
    this.endDate,
    this.budget,
    required this.status,
    required this.userId,
    required this.kepalaProyekId,
    required this.mandorId,
    this.createdAt,
    this.updatedAt,
    this.ownerName,
    this.ownerEmail,
    this.ownerPhone,
    this.kepalaProyekName,
    this.kepalaProyekEmail,
    this.kepalaProyekPhone,
    this.mandorName,
    this.mandorEmail,
    this.mandorPhone,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'].toString(),
      name: json['name'],
      description: json['description'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      budget: json['budget'],
      status: json['status'] ?? 'planning',
      userId: json['user_id'].toString(),
      kepalaProyekId: json['kepala_proyek_id'].toString(),
      mandorId: json['mandor_id'].toString(),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      ownerName: json['owner_name'],
      ownerEmail: json['owner_email'],
      ownerPhone: json['owner_phone'],
      kepalaProyekName: json['kepala_proyek_name'],
      kepalaProyekEmail: json['kepala_proyek_email'],
      kepalaProyekPhone: json['kepala_proyek_phone'],
      mandorName: json['mandor_name'],
      mandorEmail: json['mandor_email'],
      mandorPhone: json['mandor_phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'start_date': startDate,
      'end_date': endDate,
      'budget': budget,
      'status': status,
      'user_id': userId,
      'kepala_proyek_id': kepalaProyekId,
      'mandor_id': mandorId,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'planning':
        return 'Perencanaan';
      case 'ongoing':
        return 'Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'suspended':
        return 'Ditangguhkan';
      default:
        return status;
    }
  }
}
