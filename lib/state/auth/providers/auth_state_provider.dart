import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/auth_state.dart';
import '../notifiers/auth_state_notifier.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>(
    (_) => AuthStateNotifier());
