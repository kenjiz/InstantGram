import 'package:flutter/foundation.dart' show Uint8List;
import 'package:flutter/material.dart' show Image;
import './get_image_aspect_ratio.dart';

extension GetImageDataAspectRatio on Uint8List {
  Future<double> getAspectRatio() {
    final image = Image.memory(this);
    return image.getAspectRatio();
  }
}
