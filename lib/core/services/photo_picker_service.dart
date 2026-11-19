import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

/// Picks a photo from the camera or gallery (Android + iOS).
/// Wrapped behind an interface so pages can be tested without the plugin.
abstract class PhotoPickerService {
  /// Returns the local file path of the picked photo, or null if the user cancelled.
  Future<String?> pick(PhotoSource source);
}

class PhotoPickerServiceImpl implements PhotoPickerService {
  final ImagePicker _picker;

  PhotoPickerServiceImpl([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  @override
  Future<String?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera ? ImageSource.camera : ImageSource.gallery,
      preferredCameraDevice: CameraDevice.front,
      // Keep uploads small: a profile photo doesn't need full resolution.
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    return file?.path;
  }
}
