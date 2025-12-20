import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/project_controller.dart';
import '../../../../data/models/project_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/user_model.dart';

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

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController();
    descriptionController = TextEditingController();
    locationController = TextEditingController();
    budgetController = TextEditingController();
    startDateController = TextEditingController();
    endDateController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.prepareCreateForm();
    });

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
      body: Obx(() {
        if (controller.isFetchingWorkers.value) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Memuat data personel...'),
              ],
            ),
          );
        }

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionCard(
                  title: 'Informasi Project',
                  children: [
                    _buildTextField(
                      controller: nameController,
                      label: 'Nama Project *',
                      icon: Icons.title,
                      validator: (v) =>
                          v!.isEmpty ? 'Nama project wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: descriptionController,
                      label: 'Deskripsi',
                      icon: Icons.description,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: locationController,
                      label: 'Lokasi',
                      icon: Icons.location_on,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: budgetController,
                      label: 'Anggaran (Rp)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Timeline Section
                _buildSectionCard(
                  title: 'Timeline & Status',
                  children: [
                    _buildDatePicker(
                      controller: startDateController,
                      label: 'Tanggal Mulai *',
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(
                      controller: endDateController,
                      label: 'Tanggal Selesai',
                      icon: Icons.event,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(Icons.info),
                      ),
                      items: statusOptions
                          .map((s) => DropdownMenuItem(
                                value: s['value'],
                                child: Text(s['label']!),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => selectedStatus = v!),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Team Section
                _buildSectionCard(
                  title: 'Tim Proyek',
                  children: [
                    // Dropdown Pemilik
                    _buildUserDropdown(
                      label: 'Pemilik *',
                      icon: Icons.person,
                      value: selectedUserId,
                      items: controller.owners,
                      onChanged: (v) => setState(() => selectedUserId = v),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown Kepala Proyek
                    _buildUserDropdown(
                      label: 'Kepala Proyek *',
                      icon: Icons.engineering,
                      value: selectedKepalaProyekId,
                      items: controller.kepalaProyeks,
                      onChanged: (v) =>
                          setState(() => selectedKepalaProyekId = v),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown Mandor
                    _buildUserDropdown(
                      label: 'Mandor *',
                      icon: Icons.construction,
                      value: selectedMandorId,
                      items: controller.mandors,
                      onChanged: (v) => setState(() => selectedMandorId = v),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: controller.isLoading.value ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.isEdit ? 'Update Project' : 'Buat Project'),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      validator: validator,
    );
  }

  Widget _buildDatePicker({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          controller.text = date.toString().split(' ')[0];
        }
      },
    );
  }

  Widget _buildUserDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<UserModel> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: items.any((u) => u.id == value) ? value : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: items
          .map((user) => DropdownMenuItem(
                value: user.id,
                child: Text(user.name),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Wajib dipilih' : null,
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
