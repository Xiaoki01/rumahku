import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/material_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../project/controllers/project_controller.dart';

class MaterialListView extends GetView<MaterialController> {
  const MaterialListView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final projectController = Get.put(ProjectController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Material'),
      ),
      body: Column(
        children: [
          // Project Filter
          Container(
            padding: const EdgeInsets.all(16),
            color:
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Material',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  if (projectController.projects.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Tidak ada project tersedia'),
                      ),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Project',
                      prefixIcon: Icon(Icons.folder),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: controller.selectedProject.value?.id,
                    items: projectController.projects.map((project) {
                      return DropdownMenuItem(
                        value: project.id,
                        child: Text(project.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        final project = projectController.projects
                            .firstWhere((p) => p.id == value);
                        controller.selectedProject.value = project;
                        controller.fetchMaterialsByProject(value);
                      }
                    },
                  );
                }),
              ],
            ),
          ),

          // Statistics Cards
          Obx(() {
            if (controller.selectedProject.value == null) {
              return const SizedBox.shrink();
            }

            final pending =
                controller.materials.where((m) => m.status == 'pending').length;
            final approved = controller.materials
                .where((m) => m.status == 'approved')
                .length;
            final rejected = controller.materials
                .where((m) => m.status == 'rejected')
                .length;

            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Pending',
                      value: pending.toString(),
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Approved',
                      value: approved.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Rejected',
                      value: rejected.toString(),
                      icon: Icons.cancel,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Materials List
          Expanded(
            child: Obx(() {
              if (controller.selectedProject.value == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih project untuk melihat material',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.materials.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada request material',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchMaterialsByProject(
                  controller.selectedProject.value!.id,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.materials.length,
                  itemBuilder: (context, index) {
                    final material = controller.materials[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          Routes.MATERIAL_DETAIL,
                          arguments: material,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      material.materialName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  StatusBadge(
                                    status: material.status,
                                    label: material.statusDisplay,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Quantity
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer
                                      .withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.inventory, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${material.quantity} ${material.unit}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Description
                              if (material.description != null &&
                                  material.description!.isNotEmpty)
                                Text(
                                  material.description!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                              const SizedBox(height: 12),

                              // Additional Info
                              Row(
                                children: [
                                  Icon(Icons.person,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Diminta oleh: ${material.mandorName ?? "-"}',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormatter.formatDateTime(
                                        material.createdAt),
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),

                              // Approved/Rejected Info
                              if (material.status != 'pending') ...[
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Icon(
                                      material.status == 'approved'
                                          ? Icons.check_circle
                                          : Icons.cancel,
                                      size: 16,
                                      color: material.status == 'approved'
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        material.status == 'approved'
                                            ? 'Disetujui oleh: ${material.approvedByName ?? "-"}'
                                            : 'Ditolak oleh: ${material.approvedByName ?? "-"}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color:
                                                  material.status == 'approved'
                                                      ? Colors.green[700]
                                                      : Colors.red[700],
                                              fontWeight: FontWeight.w600,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: authService.isMandor
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(Routes.MATERIAL_CREATE),
              icon: const Icon(Icons.add),
              label: const Text('Request Material'),
            )
          : null,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
