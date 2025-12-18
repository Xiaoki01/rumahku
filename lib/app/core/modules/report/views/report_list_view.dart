import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../project/controllers/project_controller.dart';

class ReportListView extends GetView<ReportController> {
  const ReportListView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final projectController = Get.put(ProjectController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Harian'),
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
                  'Filter Laporan',
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
                        controller.fetchReportsByProject(value);
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

            return Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Total',
                      value: controller.totalReports.toString(),
                      icon: Icons.assignment,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Menunggu',
                      value: controller.pendingReports.toString(),
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Progress',
                      value:
                          '${controller.averageProgress.toStringAsFixed(1)}%',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Reports List
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
                        'Pilih project untuk melihat laporan',
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

              if (controller.reports.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada laporan',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchReportsByProject(
                  controller.selectedProject.value!.id,
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.reports.length,
                  itemBuilder: (context, index) {
                    final report = controller.reports[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          Routes.REPORT_DETAIL,
                          arguments: report,
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
                                      DateFormatter.formatDate(report.date),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  StatusBadge(
                                    status: report.status,
                                    label: report.statusDisplay,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Progress Bar
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Progress'),
                                      Text(
                                        '${report.progress}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value:
                                          double.parse(report.progress) / 100,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey[200],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Description
                              Text(
                                report.description,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 8),

                              // Additional Info
                              Row(
                                children: [
                                  Icon(Icons.people,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${report.jumlahTenagaKerja} Pekerja',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(width: 16),
                                  Icon(Icons.person,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      report.mandorName ?? '-',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              // Kendala if exists
                              if (report.kendala != null &&
                                  report.kendala!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.orange[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_amber,
                                        size: 16,
                                        color: Colors.orange[700],
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          report.kendala!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.orange[900],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
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
              onPressed: () => Get.toNamed(Routes.REPORT_CREATE),
              icon: const Icon(Icons.add),
              label: const Text('Buat Laporan'),
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
