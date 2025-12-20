import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/material_controller.dart';
import '../../../../data/models/material_model.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';

class MaterialDetailView extends StatelessWidget {
  const MaterialDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final MaterialModel material = Get.arguments;
    final authService = Get.find<AuthService>();
    final controller = Get.put(MaterialController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Material'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    material.materialName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(
                    status: material.status,
                    label: material.statusDisplay,
                  ),
                ],
              ),
            ),

            // Quantity Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    size: 40,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jumlah Permintaan',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.grey[700],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${material.quantity} ${material.unit}',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Project Info
                  if (material.projectName != null) ...[
                    _InfoSection(
                      title: 'Project',
                      icon: Icons.folder,
                      child: Text(
                        material.projectName!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  if (material.description != null &&
                      material.description!.isNotEmpty) ...[
                    _InfoSection(
                      title: 'Keterangan',
                      icon: Icons.description,
                      child: Text(
                        material.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Request Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Request',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Divider(height: 24),
                          _InfoTile(
                            icon: Icons.construction,
                            label: 'Diminta oleh',
                            value: material.mandorName ?? '-',
                          ),
                          const SizedBox(height: 12),
                          _InfoTile(
                            icon: Icons.access_time,
                            label: 'Tanggal Request',
                            value: DateFormatter.formatDateTime(
                                material.createdAt),
                          ),

                          // Approval Info
                          if (material.status != 'pending') ...[
                            const Divider(height: 24),
                            _InfoTile(
                              icon: material.status == 'approved'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              iconColor: material.status == 'approved'
                                  ? Colors.green
                                  : Colors.red,
                              label: material.status == 'approved'
                                  ? 'Disetujui oleh'
                                  : 'Ditolak oleh',
                              value: material.approvedByName ?? '-',
                            ),
                            const SizedBox(height: 12),
                            _InfoTile(
                              icon: Icons.event,
                              iconColor: material.status == 'approved'
                                  ? Colors.green
                                  : Colors.red,
                              label: 'Tanggal',
                              value: material.approvedAt != null
                                  ? DateFormatter.formatDateTime(
                                      material.approvedAt)
                                  : '-',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if ((authService.isKepalaProyek || authService.isAdmin) &&
                      material.status == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child: Obx(() => OutlinedButton.icon(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () =>
                                        controller.rejectMaterial(material.id),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.cancel),
                                label: const Text('Tolak'),
                              )),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Obx(() => ElevatedButton.icon(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () =>
                                        controller.approveMaterial(material.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                icon: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.check_circle),
                                label: const Text('Setujui'),
                              )),
                        ),
                      ],
                    ),
                  ],

                  // Status Info
                  if (material.status != 'pending') ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: material.status == 'approved'
                            ? Colors.green[50]
                            : Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: material.status == 'approved'
                              ? Colors.green[200]!
                              : Colors.red[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            material.status == 'approved'
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: material.status == 'approved'
                                ? Colors.green[700]
                                : Colors.red[700],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              material.status == 'approved'
                                  ? 'Material ini telah disetujui dan siap untuk diproses'
                                  : 'Request material ini telah ditolak',
                              style: TextStyle(
                                color: material.status == 'approved'
                                    ? Colors.green[900]
                                    : Colors.red[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Metadata
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dibuat: ${DateFormatter.formatDateTime(material.createdAt)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        ),
                        if (material.updatedAt != material.createdAt) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Diupdate: ${DateFormatter.formatDateTime(material.updatedAt)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  const _InfoSection({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon,
                size: 20,
                color: iconColor ?? Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor ?? Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
