
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Providers/error.dart';
import 'package:resell/Authentication/Providers/password_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';

import '../../../../../../constants/constants.dart';

class SignUp extends ConsumerStatefulWidget {
  const SignUp({super.key});

  @override
  ConsumerState<SignUp> createState() => _SignUpState();
}

class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text:
          newValue.text.toLowerCase(), // Convert the entire input to lowercase
      selection: newValue.selection, // Maintain cursor position
    );
  }
}

class _SignUpState extends ConsumerState<SignUp> {
  final _fnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  final fnameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();
  late AuthHandler handler;

  bool isPasswordContainEightChar = false;
  bool isPasswordContainUppercase = false;
  bool isPasswordCOntainNumber = false;
  bool isPasswordContainSpecialChar = false;
  final RegExp uppercaseRegExp = RegExp(r'[A-Z]');
  final RegExp numberRegExp = RegExp(r'[0-9]');
  final RegExp specialCharacterRegExp = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    fnameFocusNode.dispose();
    
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fnameController.dispose();
    
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void signupPressed() async {
    late BuildContext signUpContext;
    if (_fnameController.text.trim().isEmpty) {
      ref
          .read(fnameErrorProvider.notifier)
          .updateError('Please enter your Name');
    } else if (_fnameController.text.trim().length < 3) {
      ref
          .read(fnameErrorProvider.notifier)
          .updateError('Name should be atleast 3 characters');
    } else {
      ref.read(fnameErrorProvider.notifier).updateError('');
    }
    if (_emailController.text.trim().isEmpty) {
      ref
          .read(emailErrorProvider.notifier)
          .updateError('Please enter your Email Address');
    } else if (!RegExp(emailPattern).hasMatch(_emailController.text)) {
      ref
          .read(emailErrorProvider.notifier)
          .updateError('Please enter valid Email Address');
    } else {
      ref.read(emailErrorProvider.notifier).updateError('');
    }
    if (_passwordController.text.trim().isEmpty) {
      ref
          .read(passwordErrorProvider.notifier)
          .updateError('Please enter your Password');
    } else if (_passwordController.text.trim().length < 8) {
      ref
          .read(passwordErrorProvider.notifier)
          .updateError('Password should be atleast 8 characters');
    } else if (!uppercaseRegExp.hasMatch(_passwordController.text)) {
      ref
          .read(passwordErrorProvider.notifier)
          .updateError('Password should be atleast 1 uppercase character');
    } else if (!numberRegExp.hasMatch(_passwordController.text)) {
      ref
          .read(passwordErrorProvider.notifier)
          .updateError('Password should be atleast 1 Number');
    } else if (!specialCharacterRegExp.hasMatch(_passwordController.text)) {
      ref
          .read(passwordErrorProvider.notifier)
          .updateError('Password should be atleast 1 Special Character');
    } else {
      ref.read(passwordErrorProvider.notifier).updateError('');
    }
    if (_confirmPasswordController.text.trim().isEmpty) {
      ref
          .read(confirmPasswordErrorProvider.notifier)
          .updateError('Please enter your Confirm Password');
    } else if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      ref
          .read(confirmPasswordErrorProvider.notifier)
          .updateError('Password does not match');
      return;
    } else {
      ref.read(confirmPasswordErrorProvider.notifier).updateError('');
    }
    final fnameError = ref.read(fnameErrorProvider);
    final emailError = ref.read(emailErrorProvider);
    final passwordError = ref.read(passwordErrorProvider);
    final confirmPasswordError = ref.read(confirmPasswordErrorProvider);
    if (fnameError.isEmpty &&
        emailError.isEmpty &&
        passwordError.isEmpty &&
        confirmPasswordError.isEmpty) {
      unfocusTextFields();
      final internetChecker = await InternetConnection().hasInternetAccess;
      if (internetChecker) {
        showCupertinoDialog(
            context: context,
            builder: (ctx) {
              signUpContext = ctx;
              handler.signUp(
                  _emailController.text.trim(),
                  _passwordController.text.trim(),
                  context,
                  signUpContext,
                  _fnameController.text.trim());
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 15,
                ),
              );
            });
      } else {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              return CupertinoAlertDialog(
                title: Text(
                  'No Internet Connection',
                  style: GoogleFonts.roboto(),
                ),
                content: Text(
                  'Please check your internet connection and try again.',
                  style: GoogleFonts.roboto(),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: Text(
                      'Okay',
                      style: GoogleFonts.roboto(),
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
      }
    }
  }

  void unfocusTextFields() {
    fnameFocusNode.unfocus();
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();
  }

 

  SizedBox getTextField(String textGiven, TextEditingController controller,
      IconData data, TextInputType type, FocusNode focusNode, String error) {
    return SizedBox(
      height: 75,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: textGiven,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: error.isNotEmpty
                    ? CupertinoColors.systemRed
                    : CupertinoColors.black,
              ),
              children: [
                TextSpan(
                  text: '*',
                  style: GoogleFonts.roboto(
                    color: CupertinoColors.systemRed,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            child: CupertinoTextField(
              inputFormatters: controller == _emailController
                  ? [
                      LowerCaseTextFormatter(),
                    ]
                  : null,
              focusNode: focusNode,
              keyboardType: type,
              prefix: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  data,
                  color: CupertinoColors.black,
                ),
              ),
              controller: controller,
              cursorColor: CupertinoColors.black,
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: error.isNotEmpty
                      ? CupertinoColors.systemRed
                      : CupertinoColors.systemGrey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void changingStateOfPassword(String value) {
    setState(() {
      isPasswordContainEightChar = value.length >= 8;
      isPasswordContainUppercase = uppercaseRegExp.hasMatch(value);
      isPasswordCOntainNumber = numberRegExp.hasMatch(value);
      isPasswordContainSpecialChar = specialCharacterRegExp.hasMatch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Constants.screenBgColor,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(emailErrorProvider.notifier).updateError('');
                      ref.read(passwordErrorProvider.notifier).updateError('');
                      ref
                          .read(confirmPasswordErrorProvider.notifier)
                          .updateError('');
                      ref.read(fnameErrorProvider.notifier).updateError('');

                      Navigator.of(context).pop();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration:const BoxDecoration(
                          color: Constants.white, shape: BoxShape.circle),
                      child:const Icon(
                        CupertinoIcons.back,
                        size: 30,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Sign Up',
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final fnameError = ref.watch(fnameErrorProvider);
                      return getTextField(
                          'Name',
                          _fnameController,
                          CupertinoIcons.person_add_solid,
                          TextInputType.name,
                          fnameFocusNode,
                          fnameError);
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final fnameError = ref.watch(fnameErrorProvider);
                      return fnameError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                fnameError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final emailError = ref.watch(emailErrorProvider);
                      return getTextField(
                          'Email',
                          _emailController,
                          CupertinoIcons.mail_solid,
                          TextInputType.emailAddress,
                          emailFocusNode,
                          emailError);
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final emailError = ref.watch(emailErrorProvider);
                      return emailError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                emailError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (ctx, ref, child) {
                      final passError = ref.watch(passwordErrorProvider);
                      return SizedBox(
                        height: 75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Password',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: passError.isNotEmpty
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: GoogleFonts.roboto(
                                      color: CupertinoColors.systemRed,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final showPassword =
                                    ref.watch(signupPasswordProviderNotifier);
                                return Expanded(
                                  child: CupertinoTextField(
                                    onChanged: (value) {
                                      changingStateOfPassword(value);
                                    },
                                    focusNode: passwordFocusNode,
                                    prefix: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        CupertinoIcons.lock_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    obscureText: !showPassword,
                                    suffix: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        ref
                                            .read(signupPasswordProviderNotifier
                                                .notifier)
                                            .togglePassword();
                                      },
                                      child: Icon(
                                        showPassword
                                            ? CupertinoIcons.eye_fill
                                            : CupertinoIcons.eye_slash_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    controller: _passwordController,
                                    cursorColor: CupertinoColors.black,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: passError.isNotEmpty
                                            ? CupertinoColors.systemRed
                                            : CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final passwordError = ref.watch(passwordErrorProvider);
                      return passwordError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                passwordError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          AnimatedContainer(
                            duration:const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoColors.systemGrey,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: isPasswordContainEightChar
                                  ?const Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: CupertinoColors.activeGreen,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ),
                         const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Contain Atleast 8 Characters!',
                            style: GoogleFonts.roboto(
                              color: CupertinoColors.black,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration:const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoColors.systemGrey,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: isPasswordContainUppercase
                                  ? const Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: CupertinoColors.activeGreen,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Contain 1 Uppercase Letter',
                            style: GoogleFonts.roboto(
                                color: CupertinoColors.black, fontSize: 15),
                          )
                        ],
                      ),
                     const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration:const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoColors.systemGrey,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: isPasswordCOntainNumber
                                  ?const Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: CupertinoColors.activeGreen,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Contain 1 Number',
                            style: GoogleFonts.roboto(
                              color: CupertinoColors.black,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: CupertinoColors.systemGrey,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: isPasswordContainSpecialChar
                                  ?const Icon(
                                      CupertinoIcons.check_mark_circled_solid,
                                      color: CupertinoColors.activeGreen,
                                      size: 18,
                                    )
                                  : null,
                            ),
                          ),
                         const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Contain 1 Special Character',
                            style: GoogleFonts.roboto(
                                color: CupertinoColors.black, fontSize: 15),
                          )
                        ],
                      )
                    ],
                  ),
                 const SizedBox(
                    height: 10,
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final cpError = ref.watch(confirmPasswordErrorProvider);
                      return SizedBox(
                        height: 75,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Confirm Password',
                                style: GoogleFonts.lato(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: cpError.isNotEmpty
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.black,
                                ),
                                children: [
                                  TextSpan(
                                    text: '*',
                                    style: GoogleFonts.roboto(
                                      color: CupertinoColors.systemRed,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Consumer(
                              builder: (context, ref, child) {
                                final showConfirmPassword = ref.watch(
                                    signupConfirmPasswordProviderNotifier);
                                return Expanded(
                                  child: CupertinoTextField(
                                    focusNode: confirmPasswordFocusNode,
                                    prefix: const Padding(
                                      padding: EdgeInsets.only(left: 10),
                                      child: Icon(
                                        CupertinoIcons.lock_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    obscureText: !showConfirmPassword,
                                    suffix: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        ref
                                            .read(
                                                signupConfirmPasswordProviderNotifier
                                                    .notifier)
                                            .togglePassword();
                                      },
                                      child: Icon(
                                        showConfirmPassword
                                            ? CupertinoIcons.eye_fill
                                            : CupertinoIcons.eye_slash_fill,
                                        color: CupertinoColors.black,
                                      ),
                                    ),
                                    controller: _confirmPasswordController,
                                    padding:
                                        const EdgeInsets.only(top: 0, left: 10),
                                    cursorColor: CupertinoColors.black,
                                    decoration: BoxDecoration(
                                      color: CupertinoColors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      border: Border.all(
                                        color: cpError.isNotEmpty
                                            ? CupertinoColors.systemRed
                                            : CupertinoColors.systemGrey,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  Consumer(
                    builder: (context, ref, child) {
                      final confirmPasswordError =
                          ref.watch(confirmPasswordErrorProvider);
                      return confirmPasswordError.isEmpty
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                confirmPasswordError,
                                style: GoogleFonts.roboto(
                                    color: CupertinoColors.systemRed,
                                    fontSize: 16),
                              ),
                            );
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      padding: EdgeInsets.zero,
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () {
                        signupPressed();
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
