import 'dart:io';
import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Providers/error.dart';
import 'package:resell/Authentication/Providers/password_provider.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/constants/constants.dart';

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

class SignUpAI extends ConsumerStatefulWidget {
  const SignUpAI({super.key});

  @override
  ConsumerState<SignUpAI> createState() => _SignUpAIState();
}

class _SignUpAIState extends ConsumerState<SignUpAI> {
  final _signupFormkey = GlobalKey<FormState>();
  late AuthHandler handler;
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final String emailPattern =
      r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  final FocusNode fnameFocusNode = FocusNode();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode confirmPasswordFocusNode = FocusNode();
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

  void unfocusTextFields() {
    fnameFocusNode.unfocus();
    emailFocusNode.unfocus();
    passwordFocusNode.unfocus();
    confirmPasswordFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  void signupPressed() async {
    late BuildContext signUpContext;
    if (Platform.isAndroid) {
      if (!_signupFormkey.currentState!.validate()) {
        return;
      }
      unfocusTextFields();
      final internetcheck = await InternetConnection().hasInternetAccess;
      if (!internetcheck) {
        noInternetDialog();
      } else {
        showDialog(
          context: context,
          builder: (ctx) {
            signUpContext = ctx;
            handler.signUp(
              _emailController.text,
              _passwordController.text,
              context,
              signUpContext,
              _fnameController.text,
            );
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            );
          },
        );
      }
    } else if (Platform.isIOS) {
      // Name Validate ios
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
      // Email Validate ios
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
      // Password Validate ios
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
      // Confirm Password Validate ios
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
        if (!internetChecker) {
          noInternetDialog();
        } else {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              signUpContext = ctx;
              handler.signUp(
                _emailController.text.trim(),
                _passwordController.text.trim(),
                context,
                signUpContext,
                _fnameController.text.trim(),
              );
              return const Center(
                child: CupertinoActivityIndicator(
                  radius: 15,
                ),
              );
            },
          );
        }
      }
    }
  }

  void noInternetDialog() {
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text("No Internet Connection"),
            content: const Text(
                "Please check your internet connection and try again"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text(
                  "Okay",
                  style: TextStyle(color: Colors.blue),
                ),
              )
            ],
          );
        },
      );
    } else if (Platform.isIOS) {
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

  Widget nameTextFormField() {
    return TextFormField(
      cursorColor: Colors.black,
      controller: _fnameController,
      decoration: InputDecoration(
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        label: Text(
          'Name',
          style: GoogleFonts.roboto(),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        prefixIcon: const Icon(Icons.person),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your name';
        } else if (value.trim().length < 3) {
          return 'Please enter a valid name';
        }
        return null;
      },
    );
  }

  Widget emailTextFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      cursorColor: Colors.black,
      controller: _emailController,
      focusNode: emailFocusNode,
      decoration: InputDecoration(
        label: Text(
          'Email',
          style: GoogleFonts.roboto(),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        prefixIcon: const Icon(Icons.email),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(5),
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter your Email Address';
        } else if (!RegExp(emailPattern).hasMatch(value.trim())) {
          return 'Please enter a valid Email Address';
        }
        return null;
      },
    );
  }

  void changeStateOfPassword(String value) {
    setState(() {
      isPasswordContainEightChar = value.length >= 8;
      isPasswordContainUppercase = uppercaseRegExp.hasMatch(value);
      isPasswordCOntainNumber = numberRegExp.hasMatch(value);
      isPasswordContainSpecialChar = specialCharacterRegExp.hasMatch(value);
    });
  }

  Consumer passwordTextFormField() {
    return Consumer(
      builder: (context, ref, child) {
        final passwordProvider = ref.watch(loginpasswordProviderNotifier);

        return TextFormField(
          cursorColor: Colors.black,
          obscureText: !passwordProvider,
          controller: _passwordController,
          focusNode: passwordFocusNode,
          decoration: InputDecoration(
            label: Text(
              "Password",
              style: GoogleFonts.roboto(),
            ),
            labelStyle: const TextStyle(color: Colors.black),
            floatingLabelStyle: const TextStyle(color: Colors.blue),
            suffix: InkWell(
              onTap: () {
                ref
                    .read(loginpasswordProviderNotifier.notifier)
                    .togglePassword();
              },
              child: Text(
                !passwordProvider ? 'Show' : 'Hide',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            prefixIcon: const Icon(Icons.lock),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(5),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onChanged: (value) {
            changeStateOfPassword(value);
          },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter Password';
            } else if (_passwordController.text.trim().length < 8) {
              return 'Password must contain atleast 8 characters';
            } else if (!uppercaseRegExp.hasMatch(_passwordController.text)) {
              return 'Password should be atleast 1 uppercase character';
            } else if (!numberRegExp.hasMatch(_passwordController.text)) {
              return 'Password should be atleast 1 Number';
            } else if (!specialCharacterRegExp
                .hasMatch(_passwordController.text)) {
              return 'Password should be atleast 1 Special Character';
            }
            return null;
          },
        );
      },
    );
  }

  Widget confirmPasswordTextFormField() {
    return Consumer(
      builder: (context, ref, child) {
        final showConfirmPassword =
            ref.watch(signupConfirmPasswordProviderNotifier);
        return TextFormField(
          cursorColor: Colors.black,
          obscureText: !showConfirmPassword,
          controller: _confirmPasswordController,
          focusNode: confirmPasswordFocusNode,
          decoration: InputDecoration(
            label: Text(
              'Confirm Password',
              style: GoogleFonts.roboto(),
            ),
            labelStyle: const TextStyle(color: Colors.black),
            floatingLabelStyle: const TextStyle(color: Colors.blue),
            suffix: InkWell(
              onTap: () {
                ref
                    .read(signupConfirmPasswordProviderNotifier.notifier)
                    .togglePassword();
              },
              child: Text(
                !showConfirmPassword ? 'Show' : 'Hide',
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
            ),
            prefixIcon: const Icon(Icons.lock),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(5),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter Confirm Password';
            } else if (value.trim() != _passwordController.text.trim()) {
              return 'Password does not match';
            }
            return null;
          },
        );
      },
    );
  }

  Widget android() {
    return Scaffold(
      backgroundColor: Constants.screenBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Center(
                        child: Icon(
                          Icons.arrow_back,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    'Signup',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: _signupFormkey,
                    child: Column(
                      children: [
                        nameTextFormField(),
                        const SizedBox(
                          height: 30,
                        ),
                        emailTextFormField(),
                        const SizedBox(
                          height: 30,
                        ),
                        passwordTextFormField(),
                        const SizedBox(
                          height: 15,
                        ),
                        strongPassword(),
                        const SizedBox(
                          height: 30,
                        ),
                        confirmPasswordTextFormField(),
                        const SizedBox(
                          height: 30,
                        ),
                        signUpButton()
                      ],
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

  void reset() {
    ref.read(emailErrorProvider.notifier).updateError('');
    ref.read(passwordErrorProvider.notifier).updateError('');
    ref.read(confirmPasswordErrorProvider.notifier).updateError('');
    ref.read(fnameErrorProvider.notifier).updateError('');
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

  Consumer nameTextField() {
    return Consumer(
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
    );
  }

  Consumer nameError() {
    return Consumer(
      builder: (context, ref, child) {
        final fnameError = ref.watch(fnameErrorProvider);
        return fnameError.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  fnameError,
                  style: GoogleFonts.roboto(
                      color: CupertinoColors.systemRed, fontSize: 16),
                ),
              );
      },
    );
  }

  Consumer emailTextField() {
    return Consumer(
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
    );
  }

  Consumer emailError() {
    return Consumer(
      builder: (context, ref, child) {
        final emailError = ref.watch(emailErrorProvider);
        return emailError.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  emailError,
                  style: GoogleFonts.roboto(
                      color: CupertinoColors.systemRed, fontSize: 16),
                ),
              );
      },
    );
  }

  Consumer passwordTextField() {
    return Consumer(
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
                        changeStateOfPassword(value);
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
                              .read(signupPasswordProviderNotifier.notifier)
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
    );
  }

  Consumer passwordError() {
    return Consumer(
      builder: (context, ref, child) {
        final passwordError = ref.watch(passwordErrorProvider);
        return passwordError.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  passwordError,
                  style: GoogleFonts.roboto(
                      color: CupertinoColors.systemRed, fontSize: 16),
                ),
              );
      },
    );
  }

  Widget strongPassword() {
    if (Platform.isAndroid) {
      return Column(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: isPasswordContainEightChar
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
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
                  color: Colors.black,
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
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: isPasswordContainUppercase
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
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
                style: GoogleFonts.roboto(color: Colors.black, fontSize: 15),
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
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: isPasswordCOntainNumber
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
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
                  color: Colors.black,
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
                    color: Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: isPasswordContainSpecialChar
                      ? const Icon(
                          Icons.check_circle_rounded,
                          color: Colors.green,
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
                  color: Colors.black,
                  fontSize: 15,
                ),
              )
            ],
          )
        ],
      );
    } else if (Platform.isIOS) {
      return Column(
        children: [
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
                  child: isPasswordContainEightChar
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
                  child: isPasswordCOntainNumber
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
                'Contain 1 Special Character',
                style: GoogleFonts.roboto(
                    color: CupertinoColors.black, fontSize: 15),
              )
            ],
          )
        ],
      );
    }
    return const SizedBox();
  }

  Consumer confirmPassword() {
    return Consumer(
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
                  final showConfirmPassword =
                      ref.watch(signupConfirmPasswordProviderNotifier);
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
                              .read(signupConfirmPasswordProviderNotifier
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
                      padding: const EdgeInsets.only(top: 0, left: 10),
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
    );
  }

  Consumer confirmPasswordError() {
    return Consumer(
      builder: (context, ref, child) {
        final confirmPasswordError = ref.watch(confirmPasswordErrorProvider);
        return confirmPasswordError.isEmpty
            ? const SizedBox()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  confirmPasswordError,
                  style: GoogleFonts.roboto(
                      color: CupertinoColors.systemRed, fontSize: 16),
                ),
              );
      },
    );
  }

  Widget signUpButton() {
    if (Platform.isAndroid) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            signupPressed();
          },
          child: Text(
            'Sign Up',
            style: GoogleFonts.roboto(color: Colors.white),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return SizedBox(
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
      );
    }
    return const SizedBox();
  }

  Widget ios() {
    return CupertinoPageScaffold(
      child: PopScope(
        onPopInvokedWithResult: (didPop, result) {
          reset();
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Constants.screenBgColor,
          child: GestureDetector(
            onTap: () {
              unfocusTextFields();
            },
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, top: 15, right: 15),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          reset();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                              color: Constants.white, shape: BoxShape.circle),
                          child: const Icon(
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
                      nameTextField(),
                      nameError(),
                      const SizedBox(
                        height: 10,
                      ),
                      emailTextField(),
                      emailError(),
                      const SizedBox(
                        height: 10,
                      ),
                      passwordTextField(),
                      passwordError(),
                      const SizedBox(
                        height: 10,
                      ),
                      strongPassword(),
                      const SizedBox(
                        height: 10,
                      ),
                      confirmPassword(),
                      confirmPasswordError(),
                      const SizedBox(
                        height: 20,
                      ),
                      signUpButton()
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return android();
    }
    if (Platform.isIOS) {
      return ios();
    }
    return const SizedBox();
  }
}
