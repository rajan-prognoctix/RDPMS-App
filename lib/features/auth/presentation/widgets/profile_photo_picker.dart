import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/services/photo_picker_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Round profile photo with "Add photo" / "Change photo".
/// Tapping opens a sheet: Take photo, Choose from gallery, Remove photo.
class ProfilePhotoPicker extends StatelessWidget {
  final String? photoPath;
  final PhotoPickerService picker;
  final ValueChanged<String?> onChanged;

  const ProfilePhotoPicker({
    super.key,
    required this.photoPath,
    required this.picker,
    required this.onChanged,
  });

  static const double _size = 104;

  Future<void> _pick(BuildContext context, PhotoSource source) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final path = await picker.pick(source);
      if (path != null) onChanged(path);
    } on PlatformException {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              source == PhotoSource.camera
                  ? 'Camera not available. Allow camera access in Settings.'
                  : 'Photos not available. Allow photo access in Settings.',
            ),
          ),
        );
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        Widget option(IconData icon, String label, VoidCallback onTap, {Color? color}) => ListTile(
              leading: Icon(icon, color: color ?? AppColors.primary),
              title: Text(
                label,
                style: TextStyle(fontSize: 15, color: color ?? AppColors.textMain),
              ),
              onTap: () {
                Navigator.of(sheetContext).pop();
                onTap();
              },
            );

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(Icons.photo_camera_outlined, 'Take photo',
                  () => _pick(context, PhotoSource.camera)),
              option(Icons.photo_library_outlined, 'Choose from gallery',
                  () => _pick(context, PhotoSource.gallery)),
              if (photoPath != null)
                option(Icons.delete_outline, 'Remove photo', () => onChanged(null),
                    color: AppColors.failure),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null;

    return Column(
      children: [
        Semantics(
          button: true,
          label: hasPhoto ? 'Change profile photo' : 'Add profile photo',
          child: GestureDetector(
            onTap: () => _showOptions(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: _size,
                  height: _size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primarySoft,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: hasPhoto
                      ? Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const _Placeholder(),
                        )
                      : const _Placeholder(),
                ),
                Positioned(
                  right: 0,
                  bottom: 2,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: AppColors.buttonGradient,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.photo_camera_outlined, size: 17, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        TextButton(
          onPressed: () => _showOptions(context),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: const Size(44, 44),
            textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          child: Text(hasPhoto ? 'Change photo' : 'Add photo'),
        ),
        const Text(
          'Optional. A clear photo of your face helps the admin verify you.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) =>
      const Icon(Icons.person_outline, size: 52, color: AppColors.primary);
}
