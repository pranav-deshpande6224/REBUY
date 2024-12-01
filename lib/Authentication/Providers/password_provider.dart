import 'package:flutter_riverpod/flutter_riverpod.dart';

class PasswordProvider extends StateNotifier<bool> {
  PasswordProvider() : super(false);
  void togglePassword() {
    state = !state;
  }
}

final loginpasswordProviderNotifier =
    StateNotifierProvider<PasswordProvider, bool>(
  (_) => PasswordProvider(),
);
final signupPasswordProviderNotifier =
    StateNotifierProvider<PasswordProvider, bool>(
  (_) => PasswordProvider(),
);
final signupConfirmPasswordProviderNotifier =
    StateNotifierProvider<PasswordProvider, bool>(
  (_) => PasswordProvider(),
);
