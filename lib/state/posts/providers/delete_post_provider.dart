import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../image_upload/typedefs/is_loading.dart';
import '../notifiers/delete_post_notifier.dart';

final deletePostProvider = StateNotifierProvider<DeletePostNotifier, IsLoading>(
    (ref) => DeletePostNotifier());
