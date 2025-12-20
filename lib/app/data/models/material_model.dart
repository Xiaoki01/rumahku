class MaterialModel {
  final String id;
  final String projectId;
  final String mandorId;
  final String materialName;
  final String quantity;
  final String unit;
  final String? description;
  final String status;
  final String? approvedBy;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;

  final String? projectName;
  final String? mandorName;
  final String? approvedByName;

  MaterialModel({
    required this.id,
    required this.projectId,
    required this.mandorId,
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.description,
    required this.status,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
    this.projectName,
    this.mandorName,
    this.approvedByName,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'].toString(),
      projectId: json['project_id'].toString(),
      mandorId: json['mandor_id'].toString(),
      materialName: json['material_name'],
      quantity: json['quantity'].toString(),
      unit: json['unit'],
      description: json['description'],
      status: json['status'],
      approvedBy: json['approved_by']?.toString(),
      approvedAt: json['approved_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      projectName: json['project_name'],
      mandorName: json['mandor_name'],
      approvedByName: json['approved_by_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'material_name': materialName,
      'quantity': quantity,
      'unit': unit,
      'description': description,
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      case 'delivered':
        return 'Terkirim';
      default:
        return status;
    }
  }
}
