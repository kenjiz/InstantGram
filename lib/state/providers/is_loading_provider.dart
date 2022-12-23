import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/auth/providers/auth_state_provider.dart';
import 'package:instant_gram/state/image_upload/providers/image_uploader_provider.dart';

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  final uploadState = ref.watch(imageUploadProvider);
  return authState.isLoading || uploadState;
});
