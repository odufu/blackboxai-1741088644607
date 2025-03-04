import 'package:flutter/material.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/modern_button.dart';
import '../../widgets/error_dialog.dart';
import '../../models/stand_model.dart';
import '../../services/data_service.dart';

class StandAllocationScreen extends StatefulWidget {
  const StandAllocationScreen({super.key});

  @override
  State<StandAllocationScreen> createState() => _StandAllocationScreenState();
}

class _StandAllocationScreenState extends State<StandAllocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final DataService _dataService = DataService();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exhibitorNameController = TextEditingController();
  final _exhibitorContactController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _standId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeForm();
    });
  }

  void _initializeForm() {
    final stand = ModalRoute.of(context)?.settings.arguments as Stand?;
    if (stand != null) {
      setState(() {
        _isEditing = true;
        _standId = stand.id;
        _nameController.text = stand.name;
        _descriptionController.text = stand.description;
        _exhibitorNameController.text = stand.exhibitorName;
        _exhibitorContactController.text = stand.exhibitorContact;
        _latitudeController.text = stand.latitude.toString();
        _longitudeController.text = stand.longitude.toString();
        _imageUrlController.text = stand.imageUrl ?? '';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _exhibitorNameController.dispose();
    _exhibitorContactController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final stand = Stand(
        id: _standId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        exhibitorName: _exhibitorNameController.text,
        exhibitorContact: _exhibitorContactController.text,
        latitude: double.parse(_latitudeController.text),
        longitude: double.parse(_longitudeController.text),
        imageUrl: _imageUrlController.text.isEmpty ? null : _imageUrlController.text,
      );

      bool success;
      if (_isEditing) {
        success = await _dataService.updateStand(stand);
      } else {
        success = await _dataService.addStand(stand);
      }

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        await ErrorDialog.show(
          context: context,
          title: 'Error',
          message: 'Failed to ${_isEditing ? 'update' : 'add'} stand.',
          buttonText: 'OK',
        );
      }
    } catch (e) {
      if (!mounted) return;
      await ErrorDialog.show(
        context: context,
        title: 'Error',
        message: e.toString(),
        buttonText: 'OK',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? 'Edit Stand' : 'Allocate Stand',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stand Information Section
                _buildSectionTitle('Stand Information'),
                _buildTextField(
                  controller: _nameController,
                  label: 'Stand Name',
                  icon: Icons.store,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter stand name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  icon: Icons.description,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Exhibitor Information Section
                _buildSectionTitle('Exhibitor Information'),
                _buildTextField(
                  controller: _exhibitorNameController,
                  label: 'Exhibitor Name',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter exhibitor name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _exhibitorContactController,
                  label: 'Contact Information',
                  icon: Icons.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact information';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Location Section
                _buildSectionTitle('Location'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _latitudeController,
                        label: 'Latitude',
                        icon: Icons.location_on,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTextField(
                        controller: _longitudeController,
                        label: 'Longitude',
                        icon: Icons.location_on,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Additional Information Section
                _buildSectionTitle('Additional Information'),
                _buildTextField(
                  controller: _imageUrlController,
                  label: 'Image URL (Optional)',
                  icon: Icons.image,
                ),
                const SizedBox(height: 32),

                // Submit Button
                ModernButton(
                  text: _isEditing ? 'Update Stand' : 'Add Stand',
                  icon: _isEditing ? Icons.save : Icons.add,
                  onPressed: _handleSubmit,
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),
                if (_isEditing) ...[
                  const SizedBox(height: 16),
                  ModernOutlinedButton(
                    text: 'Delete Stand',
                    icon: Icons.delete,
                    onPressed: _handleDelete,
                    textColor: Colors.red,
                    isFullWidth: true,
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Future<void> _handleDelete() async {
    if (_standId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete this stand?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isLoading = true);

    try {
      final success = await _dataService.deleteStand(_standId!);
      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
      } else {
        await ErrorDialog.show(
          context: context,
          title: 'Error',
          message: 'Failed to delete stand.',
          buttonText: 'OK',
        );
      }
    } catch (e) {
      if (!mounted) return;
      await ErrorDialog.show(
        context: context,
        title: 'Error',
        message: e.toString(),
        buttonText: 'OK',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
