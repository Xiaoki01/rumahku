import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/report_controller.dart';
import '../../project/controllers/project_controller.dart';
import '../../../../data/services/auth_service.dart';

class ReportFormView extends StatelessWidget {
  const ReportFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportController());
    final projectController = Get.put(ProjectController());
    final authService = Get.find<AuthService>();

    // Check
    if (!authService.isMandor) {
      return Scaffold(
        appBar: AppBar(title: const Text('Buat Laporan')),
        body: const Center(
          child: Text('Hanya mandor yang dapat membuat laporan'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan Harian'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Isi laporan harian dengan lengkap',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Project Selection
            _buildSectionTitle('Project *'),
            const SizedBox(height: 8),
            Obx(() {
              if (projectController.projects.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Tidak ada project tersedia'),
                );
              }

              return DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Pilih Project',
                  prefixIcon: const Icon(Icons.folder, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 16,
                  ),
                ),
                value: controller.selectedProject.value?.id,
                items: projectController.projects.map((project) {
                  return DropdownMenuItem(
                    value: project.id,
                    child: Text(
                      project.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    final project = projectController.projects
                        .firstWhere((p) => p.id == value);
                    controller.selectedProject.value = project;
                  }
                },
              );
            }),

            const SizedBox(height: 20),

            // Date
            _buildSectionTitle('Tanggal *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.dateController,
              decoration: InputDecoration(
                labelText: 'Pilih Tanggal',
                prefixIcon: const Icon(Icons.calendar_today, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  controller.dateController.text =
                      DateFormat('yyyy-MM-dd').format(date);
                }
              },
            ),

            const SizedBox(height: 20),

            // Progress
            _buildSectionTitle('Progress (%) *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.progressController,
              decoration: InputDecoration(
                labelText: 'Contoh: 25.5',
                prefixIcon: const Icon(Icons.trending_up, size: 20),
                suffixText: '%',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),

            const SizedBox(height: 20),

            // Description
            _buildSectionTitle('Deskripsi Pekerjaan *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.descriptionController,
              decoration: InputDecoration(
                labelText: 'Jelaskan pekerjaan hari ini',
                prefixIcon: const Icon(Icons.description, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 20),

            // Kendala
            _buildSectionTitle('Kendala (Opsional)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.kendalaController,
              decoration: InputDecoration(
                labelText: 'Jelaskan kendala jika ada',
                prefixIcon: const Icon(Icons.warning_amber, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),

            // Workers Count
            _buildSectionTitle('Jumlah Tenaga Kerja *'),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.jumlahTenagaKerjaController,
              decoration: InputDecoration(
                labelText: 'Contoh: 10',
                prefixIcon: const Icon(Icons.people, size: 20),
                suffixText: 'orang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 24),

            // Photo Upload Section
            _buildSectionTitle('Foto Lapangan'),
            const SizedBox(height: 8),

            // Photo Preview Container
            Obx(() {
              if (controller.selectedImage.value != null) {
                return Column(
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            controller.selectedImage.value!,
                            width: double.infinity,
                            height: 250,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon:
                                  const Icon(Icons.close, color: Colors.white),
                              onPressed: () {
                                controller.selectedImage.value = null;
                              },
                              padding: const EdgeInsets.all(8),
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }

              // Empty state
              return Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada foto',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              );
            }),

            // Upload Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await controller.pickImage();
                },
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Tambah Foto'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.purple, width: 2),
                  foregroundColor: Colors.purple,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Info photo
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 18, color: Colors.purple[700]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Foto akan tersimpan setelah laporan dikirim',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton.icon(
                    onPressed: controller.isLoading.value
                        ? null
                        : () => controller.createReport(),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      controller.isLoading.value
                          ? 'Mengirim...'
                          : 'Kirim Laporan',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}
