import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/old/old_ios/ios_ui/IOS_Files/screens/bottom_nav_bar.dart';
import 'package:resell/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerification extends StatefulWidget {
  final String email;
  const EmailVerification({required this.email, super.key});
  @override
  State<EmailVerification> createState() => _EmailVerificationState();
}

class _EmailVerificationState extends State<EmailVerification> {
  late AuthHandler handler;
  late Timer _timer;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    sendEmailLink();
    timerForVerify();
    super.initState();
  }

  void sendEmailLink() {
    handler.sendLinkToEmail();
  }

  void resendEmailLink() {
    _timer.cancel();
    sendEmailLink();
    timerForVerify();
  }

  void timerForVerify() {
    _timer = Timer.periodic(
      const Duration(seconds: 2),
      (timer) async {
        handler.firebaseAuth.currentUser!.reload();
        final user = handler.firebaseAuth.currentUser;
        if (user!.emailVerified) {
          handler.newUser.user = handler.firebaseAuth.currentUser;
          _timer.cancel();
          final pref = await SharedPreferences.getInstance();
          await pref.setString('uid', handler.newUser.user!.uid);
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              CupertinoPageRoute(
                builder: (context) => const BottomNavBar(),
              ),
              (Route<dynamic> route) => false,
            );
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Constants.screenBgColor,
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
            child: Center(
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: const CircleAvatar(
                          backgroundColor: Constants.white,
                          child: Icon(
                            CupertinoIcons.back,
                            size: 30,
                            color: CupertinoColors.activeBlue,
                          ),
                        ),
                      ),
                      const Spacer()
                    ],
                  ),
                  Image.asset(
                    height: 100,
                    width: 100,
                    'assets/images/email.png',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'An Email link has been sent to the mail id',
                    style: GoogleFonts.lato(
                        fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FittedBox(
                    child: Text(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      widget.email,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        color: CupertinoColors.activeBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Link is for verification of your Email',
                    style: GoogleFonts.lato(),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.activeBlue,
                      onPressed: () async {
                        final checkInternet =
                            await InternetConnection().hasInternetAccess;
                        if (checkInternet) {
                          showCupertinoDialog(
                            context: context,
                            builder: (ctx) {
                              return CupertinoAlertDialog(
                                title: Text("Alert", style: GoogleFonts.lato()),
                                content: Text(
                                  "A New verification link will be sent to your email address ${widget.email}",
                                  style: GoogleFonts.lato(),
                                ),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text("Okay"),
                                    onPressed: () {
                                      resendEmailLink();
                                      Navigator.of(ctx).pop();
                                    },
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          showCupertinoDialog(
                            context: context,
                            builder: (ctx) {
                              return CupertinoAlertDialog(
                                title: const Text(' Alert'),
                                content: const Text(
                                    'No Internet Connection Please check your internet connection and try again'),
                                actions: [
                                  CupertinoDialogAction(
                                    child: const Text("Okay"),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Text(
                        'Resend Email',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
