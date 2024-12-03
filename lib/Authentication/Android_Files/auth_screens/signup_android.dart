
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Providers/password_provider.dart';
import 'package:resell/Authentication/handlers/auth_handler.dart';
import 'package:resell/constants/constants.dart';

class SignupAndroid extends StatefulWidget {
  const SignupAndroid({super.key});

  @override
  State<SignupAndroid> createState() => _SignupAndroidState();
}

class _SignupAndroidState extends State<SignupAndroid> {
  late AuthHandler handler;
  final _signupFormkey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final emailPattern = r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$';
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void changeStateOfPassword(String value) {
    setState(() {
      isPasswordContainEightChar = value.length >= 8;
      isPasswordContainUppercase = uppercaseRegExp.hasMatch(value);
      isPasswordCOntainNumber = numberRegExp.hasMatch(value);
      isPasswordContainSpecialChar = specialCharacterRegExp.hasMatch(value);
    });
  }

  void signupPressed() async {
    if (!_signupFormkey.currentState!.validate()) {
      return;
    }
    late BuildContext signUpContext;
    FocusScope.of(context).unfocus();
    final internetcheck = await InternetConnection().hasInternetAccess;
    if (internetcheck) {
      showDialog(
          context: context,
          builder: (ctx) {
            signUpContext = ctx;
            handler.signUp(
              _emailController.text,
              _passwordController.text,
              context,
              signUpContext,
              _nameController.text,
            );
            return Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            );
          });
    } else {
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
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    child: CircleAvatar(
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
                        TextFormField(
                          cursorColor: Colors.black,
                          controller: _nameController,
                          decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            hintText: 'Name',
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
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.black,
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your Email Address';
                            } else if (!RegExp(emailPattern)
                                .hasMatch(value.trim())) {
                              return 'Please enter a valid Email Address';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final passwordProvider =
                                ref.watch(loginpasswordProviderNotifier);

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
                                        .read(loginpasswordProviderNotifier
                                            .notifier)
                                        .togglePassword();
                                  },
                                  child: Text(
                                    !passwordProvider ? 'Show' : 'Hide',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              onChanged: (value) {
                                changeStateOfPassword(value);
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter Password';
                                } else if (_passwordController.text
                                        .trim()
                                        .length <
                                    8) {
                                  return 'Password must contain atleast 8 characters';
                                } else if (!uppercaseRegExp
                                    .hasMatch(_passwordController.text)) {
                                  return 'Password should be atleast 1 uppercase character';
                                } else if (!numberRegExp
                                    .hasMatch(_passwordController.text)) {
                                  return 'Password should be atleast 1 Number';
                                } else if (!specialCharacterRegExp
                                    .hasMatch(_passwordController.text)) {
                                  return 'Password should be atleast 1 Special Character';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
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
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Contain Atleast 8 Characters!',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
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
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Contain 1 Uppercase Letter',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 15),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
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
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Contain 1 Number',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 500),
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
                                        ? Icon(
                                            Icons.check_circle_rounded,
                                            color: Colors.green,
                                            size: 18,
                                          )
                                        : null,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  'Contain 1 Special Character',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Consumer(
                          builder: (context, ref, child) {
                            final showConfirmPassword = ref
                                .watch(signupConfirmPasswordProviderNotifier);
                            return TextFormField(
                              cursorColor: Colors.black,
                              obscureText: !showConfirmPassword,
                              controller: _confirmPasswordController,
                              focusNode: _confirmPasswordFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                suffix: InkWell(
                                  onTap: () {
                                    ref
                                        .read(
                                            signupConfirmPasswordProviderNotifier
                                                .notifier)
                                        .togglePassword();
                                  },
                                  child: Text(
                                    !showConfirmPassword ? 'Show' : 'Hide',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                prefixIcon: const Icon(Icons.lock),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter Confirm Password';
                                } else if (value.trim() !=
                                    _passwordController.text.trim()) {
                                  return 'Password does not match';
                                }
                                return null;
                              },
                            );
                          },
                        ),
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
                              signupPressed();
                            },
                            child: Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
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
}
