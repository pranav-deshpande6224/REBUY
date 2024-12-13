import 'dart:io';

import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Providers/error.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/constants/constants.dart';

class ForgetPasswordAI extends ConsumerStatefulWidget {
  const ForgetPasswordAI({super.key});

  @override
  ConsumerState<ForgetPasswordAI> createState() => _ForgetPasswordAIState();
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

class _ForgetPasswordAIState extends ConsumerState<ForgetPasswordAI> {
  final _forgetPasswordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  late AuthHandler handler;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    super.initState();
  }

  unfocusTextFields() {
    _emailFocusNode.unfocus();
    FocusScope.of(context).unfocus();
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

  void submitPressed() async {
    if (Platform.isAndroid) {
      if (!_forgetPasswordFormKey.currentState!.validate()) {
        return;
      }
      unfocusTextFields();
      final internetChecker = await InternetConnection().hasInternetAccess;
      if (internetChecker) {
        late BuildContext forgetPasswordContext;
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              forgetPasswordContext = ctx;
              forgetPasswordContext = ctx;
              handler.forgetPassword(
                _emailController.text.trim(),
                context,
                forgetPasswordContext,
              );
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            });
      } else {
        noInternetDialog();
      }
    } else if (Platform.isIOS) {
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
      final emailError = ref.read(emailErrorProvider);
      if (emailError.isEmpty) {
        unfocusTextFields();
        final internetChecker = await InternetConnection().hasInternetAccess;
        if (internetChecker) {
          late BuildContext forgetPasswordContext;
          showCupertinoDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              forgetPasswordContext = ctx;
              handler.forgetPassword(
                  _emailController.text.trim(), context, forgetPasswordContext);
              return const Center(
                child: CupertinoActivityIndicator(
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

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  Widget emailTextFormField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      cursorColor: Colors.black,
      controller: _emailController,
      focusNode: _emailFocusNode,
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

  Widget android() {
    return Scaffold(
      backgroundColor: Constants.screenBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                  'Forget Password',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Form(
                  key: _forgetPasswordFormKey,
                  child: Column(
                    children: [
                      emailTextFormField(),
                      const SizedBox(
                        height: 30,
                      ),
                      submit()
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget emailTextFieldIos() {
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

  Widget emailError() {
    return Consumer(
      builder: (context, ref, child) {
        final emailError = ref.watch(emailErrorProvider);
        return emailError.isEmpty
            ? const SizedBox(
                height: 0,
                width: 0,
              )
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

  Widget submit() {
    if (Platform.isAndroid) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: BeveledRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          onPressed: () {
            submitPressed();
          },
          child: const Text(
            'Submit',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return SizedBox(
        height: 50,
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          onPressed: () {
            submitPressed();
          },
          child: Text(
            'Submit',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget ios() {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        ref.read(emailErrorProvider.notifier).updateError('');
      },
      child: CupertinoPageScaffold(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          color: Constants.screenBgColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(emailErrorProvider.notifier).updateError('');
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
                    'Forget Password',
                    style: GoogleFonts.roboto(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  emailTextFieldIos(),
                  emailError(),
                  const SizedBox(
                    height: 20,
                  ),
                  submit()
                ],
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
