import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/photo_picker_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/widgets/profile_photo_picker.dart';
import '../cubit/profile_cubit.dart';

/// Edit profile: the user can change only their photo. Name, mobile, email
/// and role are set by the admin (§11.6) and shown read-only.
class EditProfilePage extends StatefulWidget {
  /// Defaults to the registered [PhotoPickerService]; pass one in tests.
  final PhotoPickerService? photoPicker;

  const EditProfilePage({super.key, this.photoPicker});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final PhotoPickerService _photoPicker = widget.photoPicker ?? sl<PhotoPickerService>();
  late final _profile = context.read<ProfileCubit>().state.profile;
  late String? _photoPath = _profile?.photoPath;

  Future<void> _save() async {
    final profile = _profile;
    if (profile == null) return;
    final messenger = ScaffoldMessenger.of(context);
    // Name is read-only, so the saved name is sent back unchanged.
    final error = await context.read<ProfileCubit>().save(name: profile.name, photoPath: _photoPath);
    if (!mounted) return;
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(error ?? 'Profile updated')));
    if (error == null) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final saving = context.select((ProfileCubit c) => c.state.saving);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit profile')),
        body: profile == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ProfilePhotoPicker(
                      photoPath: _photoPath,
                      picker: _photoPicker,
                      onChanged: (path) => setState(() => _photoPath = path),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ReadOnlyField(label: 'Name', value: profile.name),
                          const SizedBox(height: 12),
                          _ReadOnlyField(label: 'Mobile', value: profile.mobile),
                          const SizedBox(height: 12),
                          _ReadOnlyField(label: 'Email', value: profile.email),
                          const SizedBox(height: 12),
                          _ReadOnlyField(label: 'Role', value: '${profile.roleLabel} level user'),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.textMuted),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Contact your admin to change these.',
                                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
        bottomNavigationBar: profile == null
            ? null
            : Padding(
                padding: AppSpacing.cardPadding,
                child: GradientButton(
                  label: 'Save',
                  loading: saving,
                  // Enabled only once a new photo is picked or the photo is removed.
                  onPressed: _photoPath != profile.photoPath ? _save : null,
                ),
              ),
      ),
    );
  }
}

/// Greyed field with a lock icon for values only the admin can change.
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return LabeledField(
      label: label,
      child: TextFormField(
        initialValue: value,
        enabled: false,
        style: const TextStyle(color: AppColors.textMuted),
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.lock_outline, size: 18, color: AppColors.textMuted),
        ),
      ),
    );
  }
}
