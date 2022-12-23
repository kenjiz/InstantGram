import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/post_settings/notifiers/post_settings_notifier.dart';

import '../models/post_setting.dart';

final postSettingsProvider =
    StateNotifierProvider<PostSettingsNotifier, Map<PostSetting, bool>>(
  (ref) => PostSettingsNotifier(),
);
