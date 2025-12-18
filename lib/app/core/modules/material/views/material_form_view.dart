import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/material_controller.dart';
import '../../project/controllers/project_controller.dart';

class MaterialFormView extends GetView<MaterialController> {
  const MaterialFormView({super.key});

  @override
  Widget build(BuildContext context) {
    // Load projects untuk dropdown
    final projectController = Get.put(ProjectController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Material'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Project Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Project',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
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
                          labelText: 'Project',
                          prefixIcon: Icon(Icons.folder),
                        ),
                        value: controller.selectedProject.value?.id,
                        items: projectController.projects.map((project) {
                          return DropdownMenuItem(
                            value: project.id,
                            child: Text(project.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          final project = projectController.projects
                              .firstWhere((p) => p.id == value);
                          controller.selectedProject.value = project;
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Material Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Material',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),

                    // Material Name
                    TextField(
                      controller: controller.materialNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Material',
                        hintText: 'Contoh: Semen Gresik',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Quantity & Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: controller.quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Jumlah',
                              prefixIcon: Icon(Icons.numbers),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: controller.unitController,
                            decoration: const InputDecoration(
                              labelText: 'Satuan',
                              hintText: 'sak, m³, dll',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    TextField(
                      controller: controller.descriptionController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Keterangan',
                        hintText: 'Untuk pekerjaan...',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.createMaterialRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Kirim Request',
                          style: TextStyle(fontSize: 16),
                        ),
                )),

            const SizedBox(height: 16),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Request material akan dikirim ke Kepala Proyek untuk disetujui',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 12,
                      ),
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
