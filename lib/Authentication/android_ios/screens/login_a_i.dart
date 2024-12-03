import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Providers/error.dart';
import 'package:resell/Authentication/Providers/password_provider.dart';
import 'package:resell/Authentication/android_ios/screens/forget_password_a_i.dart';
import 'package:resell/Authentication/android_ios/screens/sign_up_a_i.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/constants/constants.dart';

class LoginAI extends ConsumerStatefulWidget {
  const LoginAI({super.key});

  @override
  ConsumerState<LoginAI> createState() => _LoginAIState();
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

class _LoginAIState extends ConsumerState<LoginAI> {
  final _formkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  late AuthHandler handler;

  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void unFocusTextFields() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  TextFormField emailTextFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      cursorColor: Colors.black,
      controller: _emailController,
      focusNode: _emailFocusNode,
      inputFormatters: [LowerCaseTextFormatter()],
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.email),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(5),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(5),
        ),
        labelStyle: const TextStyle(color: Colors.black),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        label: Text(
          'Email',
          style: GoogleFonts.roboto(),
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

  Widget passwordTextFormField() {
    return Consumer(
      builder: (context, ref, child) {
        final passwordProvider = ref.watch(loginpasswordProviderNotifier);
        return TextFormField(
          cursorColor: Colors.black,
          obscureText: !passwordProvider,
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          decoration: InputDecoration(
            hintText: 'Password',
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
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(5),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black),
              borderRadius: BorderRadius.circular(5),
            ),
            labelStyle: const TextStyle(color: Colors.black),
            floatingLabelStyle: const TextStyle(color: Colors.blue),
            label: Text(
              'Password',
              style: GoogleFonts.roboto(),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter Password';
            }
            return null;
          },
        );
      },
    );
  }

  void loginPressed() async {
    late BuildContext loginContext;
    if (Platform.isAndroid) {
      if (!_formkey.currentState!.validate()) {
        return;
      }
      unFocusTextFields();
      final internetCheck = await InternetConnection().hasInternetAccess;
      if (internetCheck) {
        showDialog(
          context: context,
          builder: (ctx) {
            loginContext = ctx;
            handler.signIn(_emailController.text, _passwordController.text,
                context, loginContext);
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            );
          },
        );
      } else {
        noInternetDialog();
      }
    } else if (Platform.isIOS) {
      // email ios
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
      // password ios
      if (_passwordController.text.trim().isEmpty) {
        ref
            .read(passwordErrorProvider.notifier)
            .updateError('Please enter your Password');
        return;
      } else {
        ref.read(passwordErrorProvider.notifier).updateError('');
      }
      final emailError = ref.read(emailErrorProvider);
      final passwordError = ref.read(passwordErrorProvider);
      if (emailError.isEmpty && passwordError.isEmpty) {
        unFocusTextFields();
        final internetChecker = await InternetConnection().hasInternetAccess;
        if (internetChecker) {
          showCupertinoDialog(
            context: context,
            builder: (ctx) {
              loginContext = ctx;
              handler.signIn(_emailController.text.trim(),
                  _passwordController.text.trim(), context, loginContext);
              return const Center(
                child: CupertinoActivityIndicator(
                  color: CupertinoColors.black,
                  radius: 15,
                ),
              );
            },
          );
        } else {
          noInternetDialog();
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

  Widget android() {
    return Scaffold(
      backgroundColor: Constants.screenBgColor,
      body: GestureDetector(
        onTap: unFocusTextFields,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        emailTextFormField(),
                        const SizedBox(
                          height: 30,
                        ),
                        passwordTextFormField(),
                        const SizedBox(
                          height: 10,
                        ),
                        forgetPasswordButton(),
                        const SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              loginPressed();
                            },
                            child: Text(
                              'Login',
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        seperator(),
                        const SizedBox(
                          height: 30,
                        ),
                        googleSignInAndApple(),
                        const SizedBox(
                          height: 50,
                        ),
                        dontHaveAccount()
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

  Consumer emailTextField() {
    return Consumer(
      builder: (context, ref, child) {
        final emailError = ref.watch(emailErrorProvider);
        return SizedBox(
          height: 75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  text: 'Email',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: emailError.isNotEmpty
                        ? CupertinoColors.systemRed
                        : CupertinoColors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: CupertinoTextField(
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: [
                    LowerCaseTextFormatter(), // Ensures all input is converted to lowercase
                  ],
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(
                      CupertinoIcons.mail_solid,
                      color: CupertinoColors.black,
                    ),
                  ),
                  controller: _emailController,
                  cursorColor: CupertinoColors.black,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: emailError.isNotEmpty
                          ? CupertinoColors.systemRed
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
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
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  emailError,
                  style: GoogleFonts.roboto(
                    color: CupertinoColors.systemRed,
                    fontSize: 16,
                  ),
                ),
              );
      },
    );
  }

  Consumer passwordTextField() {
    return Consumer(
      builder: (context, ref, child) {
        final passwordError = ref.watch(passwordErrorProvider);
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
                    color: passwordError.isNotEmpty
                        ? CupertinoColors.systemRed
                        : CupertinoColors.black,
                  ),
                  children: [
                    TextSpan(
                      text: '*',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.systemRed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final passwordProvider =
                        ref.watch(loginpasswordProviderNotifier);
                    return CupertinoTextField(
                      focusNode: _passwordFocusNode,
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: Icon(
                          CupertinoIcons.padlock_solid,
                          color: CupertinoColors.black,
                        ),
                      ),
                      controller: _passwordController,
                      obscureText: !passwordProvider,
                      suffix: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref
                              .read(loginpasswordProviderNotifier.notifier)
                              .togglePassword();
                        },
                        child: Icon(
                          passwordProvider
                              ? CupertinoIcons.eye_fill
                              : CupertinoIcons.eye_slash_fill,
                          color: CupertinoColors.darkBackgroundGray,
                        ),
                      ),
                      cursorColor: CupertinoColors.black,
                      decoration: BoxDecoration(
                        color: CupertinoColors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: passwordError.isNotEmpty
                              ? CupertinoColors.systemRed
                              : CupertinoColors.systemGrey,
                        ),
                      ),
                    );
                  },
                ),
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
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  passwordError,
                  style: GoogleFonts.roboto(
                    color: CupertinoColors.systemRed,
                    fontSize: 16,
                  ),
                ),
              );
      },
    );
  }

  Widget forgetPasswordButton() {
    if (Platform.isAndroid) {
      return Row(
        children: [
          const Spacer(),
          InkWell(
            onTap: () {
              FocusScope.of(context).unfocus();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const ForgetPasswordAI(),
                ),
              );
            },
            child: Text(
              'Forget Password?',
              style: GoogleFonts.roboto(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      );
    } else if (Platform.isIOS) {
      return Row(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () {
              ref.read(passwordErrorProvider.notifier).updateError('');
              ref.read(emailErrorProvider.notifier).updateError('');
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (ctx) => const ForgetPasswordAI(),
                ),
              );
            },
            child: Text(
              'Forget Password?',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: CupertinoColors.activeBlue,
              ),
            ),
          )
        ],
      );
    }
    return const SizedBox();
  }

  Widget seperator() {
    if (Platform.isAndroid) {
      return Row(
        children: [
          const Expanded(
            child: Divider(
              height: 1,
              color: Colors.black,
              thickness: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              'Or Sign in with',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
            ),
          ),
          const Expanded(
            child: Divider(
              height: 1,
              color: Colors.black,
              thickness: 0.5,
            ),
          ),
        ],
      );
    } else if (Platform.isIOS) {
      return Row(
        children: [
          const Expanded(
            child: Divider(
              height: 1,
              color: CupertinoColors.black,
              thickness: 0.5,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Text(
              'Or Sign in with',
              style: GoogleFonts.roboto(fontWeight: FontWeight.w400),
            ),
          ),
          const Expanded(
            child: Divider(
              height: 1,
              color: CupertinoColors.black,
              thickness: 0.5,
            ),
          ),
        ],
      );
    }
    return const SizedBox();
  }

  Widget googleSignInAndApple() {
    if (Platform.isAndroid) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: Image.asset(
            'assets/images/g_transparent.png',
            height: 25,
            width: 25,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[200],
            shape: RoundedRectangleBorder(
              side: const BorderSide(
                width: 0.5,
                color: Colors.black38,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            late BuildContext googleSignInContext;
            showDialog(
              context: context,
              builder: (ctx) {
                googleSignInContext = ctx;
                handler.googleSignIn(ref, context, googleSignInContext);
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              },
            );
          },
          label: Text(
            'Sign in With Google',
            style: GoogleFonts.roboto(color: Colors.black),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return Row(
        children: [
          const Spacer(),
          GestureDetector(
            onTap: () {
              late BuildContext googleSignInContext;
              showCupertinoDialog(
                context: context,
                builder: (ctx) {
                  googleSignInContext = ctx;
                  handler.googleSignIn(ref, context, googleSignInContext);
                  return const Center(
                    child: CupertinoActivityIndicator(
                      radius: 15,
                    ),
                  );
                },
              );
            },
            child: CircleAvatar(
              backgroundColor: CupertinoColors.white,
              radius: 30,
              child: Image.asset(
                width: 50,
                height: 50,
                'assets/images/g_transparent.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 30,
          ),
          GestureDetector(
            onTap: () {
              // TODO SignIN WITH APPLE
            },
            child: CircleAvatar(
              backgroundColor: CupertinoColors.white,
              radius: 30,
              child: Image.asset(
                width: 50,
                height: 50,
                'assets/images/apple_a.png',
                fit: BoxFit.fill,
              ),
            ),
          ),
          const Spacer()
        ],
      );
    }
    return const SizedBox();
  }

  Widget dontHaveAccount() {
    print("reaching here of don't have account");
    if (Platform.isAndroid) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Don\'t have an account?',
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => const SignUpAI(),
                ),
              );
            },
            child: const Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      );
    } else if (Platform.isIOS) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Don\'t have an account?',
            style: GoogleFonts.roboto(),
          ),
          CupertinoButton(
            onPressed: () {
              ref.read(emailErrorProvider.notifier).updateError('');
              ref.read(passwordErrorProvider.notifier).updateError('');
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (ctx) => const SignUpAI(),
                ),
              );
            },
            child: Text(
              'Sign Up',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      );
    }
    return const SizedBox();
  }

  Widget ios() {
    return CupertinoPageScaffold(
      backgroundColor: Constants.screenBgColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login',
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Welcome Back',
                  style: GoogleFonts.roboto(
                    fontSize: 20,
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                emailTextField(),
                emailError(),
                const SizedBox(
                  height: 20,
                ),
                passwordTextField(),
                passwordError(),
                const SizedBox(
                  height: 10,
                ),
                forgetPasswordButton(),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: CupertinoButton(
                    color: CupertinoColors.activeBlue,
                    onPressed: () {
                      loginPressed();
                    },
                    child: Text(
                      'Login',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                seperator(),
                const SizedBox(
                  height: 30,
                ),
                googleSignInAndApple(),
                const SizedBox(
                  height: 50,
                ),
                dontHaveAccount()
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid
        ? android()
        : Platform.isIOS
            ? ios()
            : const SizedBox();
  }
}
