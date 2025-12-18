import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../../../../data/models/project_model.dart';
import '../../../../core/constants/app_constants.dart';

class ProjectFormView extends StatefulWidget {
  final bool isEdit;

  const ProjectFormView({super.key, this.isEdit = false});

  @override
  State<ProjectFormView> createState() => _ProjectFormViewState();
}

class _ProjectFormViewState extends State<ProjectFormView> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<ProjectController>();

  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController locationController;
  late TextEditingController budgetController;
  late TextEditingController startDateController;
  late TextEditingController endDateController;

  String selectedStatus = AppConstants.statusPlanning;
  String? selectedUserId;
  String? selectedKepalaProyekId;
  String? selectedMandorId;

  final List<Map<String, String>> statusOptions = [
    {'value': AppConstants.statusPlanning, 'label': 'Perencanaan'},
    {'value': AppConstants.statusOngoing, 'label': 'Berlangsung'},
    {'value': AppConstants.statusCompleted, 'label': 'Selesai'},
    {'value': AppConstants.statusSuspended, 'label': 'Ditangguhkan'},
  ];

  // Dummy users - In real app, fetch from API
  final List<Map<String, String>> users = [
    {'id': '2', 'name': 'Budi Santoso', 'role': 'pengguna'},
    {'id': '3', 'name': 'Agus Kepala', 'role': 'kepala_proyek'},
    {'id': '4', 'name': 'Joko Mandor', 'role': 'mandor'},
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
    budgetController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();

    if (widget.isEdit) {
      final ProjectModel project = Get.arguments;
      nameController.text = project.name;
      descriptionController.text = project.description ?? '';
      locationController.text = project.location ?? '';
      budgetController.text = project.budget ?? '';
      startDateController.text = project.startDate;
      endDateController.text = project.endDate ?? '';
      selectedStatus = project.status;
      selectedUserId = project.userId;
      selectedKepalaProyekId = project.kepalaProyekId;
      selectedMandorId = project.mandorId;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    budgetController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Project' : 'Buat Project'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Project Info Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi Project',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Project *',
                          hintText: 'Contoh: Renovasi Rumah Pak Budi',
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama project tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Deskripsi detail project',
                          prefixIcon: Icon(Icons.description),
                          alignLabelWithHint: true,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi',
                          hintText: 'Alamat lengkap project',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Budget
                      TextFormField(
                        controller: budgetController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Anggaran (Rp)',
                          hintText: '50000000',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Anggaran harus berupa angka';
                            }
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Timeline Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Timeline',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Start Date
                      TextFormField(
                        controller: startDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Mulai *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            startDateController.text =
                                date.toString().split(' ')[0];
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tanggal mulai tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // End Date
                      TextFormField(
                        controller: endDateController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Selesai',
                          prefixIcon: Icon(Icons.event),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            endDateController.text =
                                date.toString().split(' ')[0];
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      // Status
                      DropdownButtonFormField<String>(
                        value: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          prefixIcon: Icon(Icons.info),
                        ),
                        items: statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status['value'],
                            child: Text(status['label']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedStatus = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Team Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tim Proyek',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Owner (Pengguna)
                      DropdownButtonFormField<String>(
                        value: selectedUserId,
                        decoration: const InputDecoration(
                          labelText: 'Pemilik *',
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: users
                            .where((u) => u['role'] == 'pengguna')
                            .map((user) {
                          return DropdownMenuItem(
                            value: user['id'],
                            child: Text(user['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedUserId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih pemilik project';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Kepala Proyek
                      DropdownButtonFormField<String>(
                        value: selectedKepalaProyekId,
                        decoration: const InputDecoration(
                          labelText: 'Kepala Proyek *',
                          prefixIcon: Icon(Icons.engineering),
                        ),
                        items: users
                            .where((u) => u['role'] == 'kepala_proyek')
                            .map((user) {
                          return DropdownMenuItem(
                            value: user['id'],
                            child: Text(user['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedKepalaProyekId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih kepala proyek';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Mandor
                      DropdownButtonFormField<String>(
                        value: selectedMandorId,
                        decoration: const InputDecoration(
                          labelText: 'Mandor *',
                          prefixIcon: Icon(Icons.construction),
                        ),
                        items: users
                            .where((u) => u['role'] == 'mandor')
                            .map((user) {
                          return DropdownMenuItem(
                            value: user['id'],
                            child: Text(user['name']!),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedMandorId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Pilih mandor';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Submit Button
              Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            widget.isEdit ? 'Update Project' : 'Buat Project',
                            style: const TextStyle(fontSize: 16),
                          ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'location': locationController.text.trim(),
        'start_date': startDateController.text,
        'end_date':
            endDateController.text.isEmpty ? null : endDateController.text,
        'budget': budgetController.text.isEmpty
            ? null
            : double.parse(budgetController.text),
        'status': selectedStatus,
        'user_id': int.parse(selectedUserId!),
        'kepala_proyek_id': int.parse(selectedKepalaProyekId!),
        'mandor_id': int.parse(selectedMandorId!),
      };

      if (widget.isEdit) {
        final ProjectModel project = Get.arguments;
        controller.updateProject(project.id, data);
      } else {
        controller.createProject(data);
      }
    }
  }
}
