import '../models/file_type.dart';

extension GetCollectionNameFromFileTypes on FileType {
  String getCollectionName() {
    switch (this) {
      case FileType.image:
        return 'images';
      case FileType.video:
        return 'videos';
    }
  }
}
