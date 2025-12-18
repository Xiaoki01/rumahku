import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/project_model.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../../../data/services/auth_service.dart';
import '../../../../routes/app_routes.dart';

class ProjectDetailView extends StatelessWidget {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final ProjectModel project = Get.arguments;
    final authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Project'),
        actions: [
          // Hanya Admin dan Kepala Proyek yang bisa edit
          if (authService.isAdmin || authService.isKepalaProyek)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Get.toNamed(
                Routes.PROJECT_EDIT,
                arguments: project,
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    project.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(
                    status: project.status,
                    label: project.statusDisplay,
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
                  // Description
                  _SectionTitle('Deskripsi'),
                  Text(project.description ?? '-'),

                  const SizedBox(height: 24),

                  // Location
                  _SectionTitle('Lokasi'),
                  Text(project.location ?? '-'),

                  const SizedBox(height: 24),

                  // Timeline
                  _SectionTitle('Timeline'),
                  Text('Mulai: ${project.startDate}'),
                  Text('Selesai: ${project.endDate ?? "Belum ditentukan"}'),

                  const SizedBox(height: 24),

                  // Budget
                  if (project.budget != null) ...[
                    _SectionTitle('Anggaran'),
                    Text(
                      CurrencyFormatter.format(project.budget),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Team
                  _SectionTitle('Tim Proyek'),
                  Card(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Pemilik'),
                          subtitle: Text(project.ownerName ?? '-'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.engineering),
                          title: const Text('Kepala Proyek'),
                          subtitle: Text(project.kepalaProyekName ?? '-'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.construction),
                          title: const Text('Mandor'),
                          subtitle: Text(project.mandorName ?? '-'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quick Actions untuk role tertentu
                  _buildQuickActions(authService, project),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(AuthService authService, ProjectModel project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Admin & Kepala Proyek bisa lihat laporan dan material
        if (authService.isAdmin || authService.isKepalaProyek) ...[
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Lihat Laporan'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(Routes.REPORT_LIST);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Lihat Material'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(Routes.MATERIAL_LIST);
            },
          ),
        ],

        // Mandor bisa input laporan dan request material
        if (authService.isMandor) ...[
          ListTile(
            leading: const Icon(Icons.assignment_add),
            title: const Text('Input Laporan'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(Routes.REPORT_CREATE);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_shopping_cart),
            title: const Text('Request Material'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(Routes.MATERIAL_CREATE);
            },
          ),
        ],

        // Pengguna hanya bisa lihat laporan (read-only)
        if (authService.isPengguna) ...[
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Lihat Laporan'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(Routes.REPORT_LIST);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Lihat Material'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Get.toNamed(Routes.MATERIAL_LIST);
            },
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
