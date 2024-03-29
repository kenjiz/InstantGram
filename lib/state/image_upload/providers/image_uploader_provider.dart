import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/image_upload/notifier/image_upload_notifier.dart';
import 'package:instant_gram/state/image_upload/typedefs/is_loading.dart';

final imageUploadProvider =
    StateNotifierProvider<ImageUploadNotifier, IsLoading>(
        (_) => ImageUploadNotifier());
