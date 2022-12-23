import 'dart:io';

import 'package:flutter/foundation.dart' show immutable;
import 'package:image_picker/image_picker.dart';

import '../extensions/to_file.dart';

@immutable
class ImagePickerHelper {
  const ImagePickerHelper._();

  static final imagePicker = ImagePicker();

  static Future<File?> pickImageFromGallery() =>
      imagePicker.pickImage(source: ImageSource.gallery).toFile();

  static Future<File?> pickVideoFromGallery() =>
      imagePicker.pickVideo(source: ImageSource.gallery).toFile();
}
