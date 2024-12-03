import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/Android_Files/auth_screens/forget_password_android.dart';
import 'package:resell/Authentication/Android_Files/auth_screens/signup_android.dart';
import 'package:resell/Authentication/Providers/password_provider.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/constants/constants.dart';

class LoginAndroid extends ConsumerStatefulWidget {
  const LoginAndroid({super.key});

  @override
  ConsumerState<LoginAndroid> createState() => _LoginAndroidState();
}

class _LoginAndroidState extends ConsumerState<LoginAndroid> {
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

  void loginPressed() async {
    if (!_formkey.currentState!.validate()) {
      return;
    }
    late BuildContext loginContext;
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
          });
    } else {
      showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('No Internet'),
            content: const Text('Please check your internet connection'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.screenBgColor,
      body: SafeArea(
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
                      TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        cursorColor: Colors.black,
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        decoration: InputDecoration(
                            hintText: 'Email',
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
                            floatingLabelStyle:
                                const TextStyle(color: Colors.blue),
                            label: const Text('Email')),
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
                      const SizedBox(
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
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(5),
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
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) =>
                                      const ForgetPasswordAndroid()));
                            },
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )
                        ],
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
                              FocusScope.of(context).unfocus();
                              loginPressed();
                            },
                            child: const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Colors.black,
                              thickness: 0.5,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'Or Sign in with',
                              style: TextStyle(fontWeight: FontWeight.w400),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              height: 1,
                              color: Colors.black,
                              thickness: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: Image.asset(
                            'assets/images/g_transparent.png',
                            height: 25,
                            width: 25,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[200],
                            shape: BeveledRectangleBorder(
                              side: const BorderSide(
                                  width: 0.5, color: Colors.black38),
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            late BuildContext googleSignInContext;
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                googleSignInContext = ctx;
                                handler.googleSignIn(
                                    ref, context, googleSignInContext);
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                  ),
                                );
                              },
                            );
                          },
                          label: const Text(
                            'Sign in With Google',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
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
                                  builder: (ctx) => const SignupAndroid(),
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
                      )
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
}
