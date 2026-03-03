import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/responsive/responsive.dart';
import '../../../user/presentation/providers/user_provider.dart';
import '../providers/sos_provider.dart';

class AddContactBottomSheet extends ConsumerStatefulWidget {
  const AddContactBottomSheet({super.key});

  @override
  ConsumerState<AddContactBottomSheet> createState() =>
      _AddContactBottomSheetState();
}

class _AddContactBottomSheetState extends ConsumerState<AddContactBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _relationshipController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _importFromContacts() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Contacts permission is required'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Settings',
              textColor: Colors.white,
              onPressed: () => openAppSettings(),
            ),
          ),
        );
      }
      return;
    }

    try {
      final contact = await FlutterContacts.openExternalPick();
      if (contact != null && mounted) {
        final fullContact = await FlutterContacts.getContact(
          contact.id,
          withProperties: true,
        );
        if (fullContact != null) {
          setState(() {
            _nameController.text = fullContact.displayName;
            if (fullContact.phones.isNotEmpty) {
              _phoneController.text = fullContact.phones.first.number;
            }
            if (fullContact.emails.isNotEmpty) {
              _emailController.text = fullContact.emails.first.address;
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to import contact'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isLoading = true);

    final notifier = ref.read(sosNotifierProvider.notifier);
    final rawPhone = _phoneController.text.trim();
    final cleanedPhone = rawPhone.startsWith('+')
        ? '+${rawPhone.substring(1).replaceAll(RegExp(r'[^\d]'), '')}'
        : rawPhone.replaceAll(RegExp(r'[^\d]'), '');

    try {
      final contact = await notifier.addContact(
        user.uid,
        name: _nameController.text.trim(),
        phone: cleanedPhone,
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        relationship: _relationshipController.text.trim().isEmpty
            ? null
            : _relationshipController.text.trim(),
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (contact != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contact added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add contact. Check your connection.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive.of(context);
    final brightness = Theme.of(context).brightness;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: brightness == Brightness.dark
            ? const Color(0xFF1A1A2E)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.w(5)),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.onSurfaceFaint(brightness),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: responsive.h(2)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Trusted Contact',
                    style: TextStyle(
                      color: AppColors.onSurface(brightness),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _importFromContacts,
                    icon: Icon(
                      Icons.contacts,
                      color: AppColors.accent,
                      size: 18,
                    ),
                    label: Text(
                      'Import',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.h(0.5)),
              Text(
                'This person will be notified during an SOS emergency',
                style: TextStyle(
                  color: AppColors.onSurfaceMuted(brightness),
                  fontSize: 14,
                ),
              ),
              SizedBox(height: responsive.h(3)),
              _buildTextField(
                context: context,
                brightness: brightness,
                controller: _nameController,
                label: 'Name',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.h(2)),
              _buildTextField(
                context: context,
                brightness: brightness,
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a phone number';
                  }
                  final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                  if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(cleaned)) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.h(2)),
              _buildTextField(
                context: context,
                brightness: brightness,
                controller: _emailController,
                label: 'Email (Optional)',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$',
                    ).hasMatch(value.trim())) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              SizedBox(height: responsive.h(2)),
              _buildTextField(
                context: context,
                brightness: brightness,
                controller: _relationshipController,
                label: 'Relationship (Optional)',
                icon: Icons.people_outline,
                hint: 'e.g., Parent, Friend, Spouse',
              ),
              SizedBox(height: responsive.h(3)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF416C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: responsive.h(2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Add Contact',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              SizedBox(height: responsive.h(2)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required BuildContext context,
    required Brightness brightness,
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? hint,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(color: AppColors.onSurface(brightness)),
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: AppColors.onSurfaceMuted(brightness)),
        hintStyle: TextStyle(color: AppColors.onSurfaceFaint(brightness)),
        prefixIcon: Icon(icon, color: AppColors.onSurfaceMuted(brightness)),
        filled: true,
        fillColor: AppColors.inputFill(brightness),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.inputBorder(brightness)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF416C)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
