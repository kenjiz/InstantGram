import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instant_gram/state/auth/backend/authenticator.dart';
import 'package:instant_gram/state/user_info/backend/user_info_storage.dart';

import '../../posts/typedefs/user_id.dart';
import '../model/auth_result.dart';
import '../model/auth_state.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  final _authenticator = const Authenticator();
  final _userInfoStorage = const UserInfoStorage();

  AuthStateNotifier()
      : super(
          const AuthState.unknown(),
        ) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.logOut();
    state = const AuthState.unknown();
  }

  Future<void> logInWithGoogle() async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.loginWithGoogle();
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId: userId);
    }
    state = AuthState(
      isLoading: false,
      result: AuthResult.success,
      userId: userId,
    );
  }

  Future<void> loginWithFacebook() async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.loginWithFacebook();
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId: userId);
    }
    state = AuthState(
      isLoading: false,
      result: AuthResult.success,
      userId: userId,
    );
  }

  Future<void> saveUserInfo({required UserId userId}) async =>
      _userInfoStorage.saveUserInfo(
        userId: userId,
        displayName: _authenticator.displayName,
        email: _authenticator.email,
      );
}
