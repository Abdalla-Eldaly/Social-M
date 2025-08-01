import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ImagePickerUtils {
  static final ImagePicker _picker = ImagePicker();

  static Future<void> pickImage(
      Function(File?) updateFunction, {
        ImageSource source = ImageSource.gallery,
      }) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      updateFunction(File(image.path));
    }
  }
}