import 'package:flutter_riverpod/flutter_riverpod.dart';

class Error extends StateNotifier<String> {
  Error() : super('');
  void updateError(String value) {
    state = value;
  }
}

final emailErrorProvider = StateNotifierProvider<Error, String>(
  (_) => Error(),
);

final passwordErrorProvider = StateNotifierProvider<Error, String>(
  (_) => Error(),
);

final confirmPasswordErrorProvider = StateNotifierProvider<Error, String>(
  (_) => Error(),
);

final fnameErrorProvider = StateNotifierProvider<Error, String>(
  (_) => Error(),
);



final brandError = StateNotifierProvider<Error, String>(
  (_) => Error(),
);

final adTitleError = StateNotifierProvider<Error, String>(
  (_) => Error(),
);

final adDescriptionError = StateNotifierProvider<Error, String>(
  (_) => Error(),
);

final ipadError = StateNotifierProvider<Error, String>((_) {
  return Error();
});

final chargerError = StateNotifierProvider<Error, String>((_) {
  return Error();
});

final priceError = StateNotifierProvider<Error, String>((_) {
  return Error();
});
