import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';

class ProjectListView extends GetView<ProjectController> {
  const ProjectListView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Project'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.projects.isEmpty) {
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
                  'Belum ada project',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchProjects,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.projects.length,
            itemBuilder: (context, index) {
              final project = controller.projects[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => Get.toNamed(
                    Routes.PROJECT_DETAIL,
                    arguments: project,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            StatusBadge(
                              status: project.status,
                              label: project.statusDisplay,
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        if (project.location != null)
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  project.location!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              '${project.startDate} - ${project.endDate ?? "Belum selesai"}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),

                        if (project.budget != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                CurrencyFormatter.format(project.budget),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                        ],

                        const Divider(height: 24),

                        // Team Info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _TeamMember(
                              icon: Icons.person,
                              label: 'Pemilik',
                              name: project.ownerName,
                            ),
                            const SizedBox(height: 4),
                            _TeamMember(
                              icon: Icons.engineering,
                              label: 'Kepala Proyek',
                              name: project.kepalaProyekName,
                            ),
                            const SizedBox(height: 4),
                            _TeamMember(
                              icon: Icons.construction,
                              label: 'Mandor',
                              name: project.mandorName,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: authService.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => Get.toNamed(Routes.PROJECT_CREATE),
              icon: const Icon(Icons.add),
              label: const Text('Buat Project'),
            )
          : null,
    );
  }
}

class _TeamMember extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? name;

  const _TeamMember({
    required this.icon,
    required this.label,
    this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        Text(
          name ?? '-',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
