import 'dart:async';
import 'dart:io';
import 'package:flutter/Cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:resell/Authentication/android_ios/handlers/auth_handler.dart';
import 'package:resell/UIPart/android_ios/screens/bottom_nav_a_i.dart';
import 'package:resell/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerificationAI extends StatefulWidget {
  final String email;
  const EmailVerificationAI({required this.email, super.key});

  @override
  State<EmailVerificationAI> createState() => _EmailVerificationAIState();
}

class _EmailVerificationAIState extends State<EmailVerificationAI> {
  late AuthHandler handler;
  late Timer _timer;
  bool isVerified = false;
  @override
  void initState() {
    handler = AuthHandler.authHandlerInstance;
    sendEmailLink();
    timerForVerify();
    super.initState();
  }

  void resendEmailLink() {
    _timer.cancel();
    sendEmailLink();
    timerForVerify();
  }

  void sendEmailLink() {
    handler.sendLinkToEmail();
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
          setState(() {
            isVerified = true;
          });
          await Future.delayed(const Duration(seconds: 2));
          final pref = await SharedPreferences.getInstance();
          await pref.setString('uid', handler.newUser.user!.uid);
          if (context.mounted) {
            if (Platform.isAndroid) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const BottomNavAI(),
                ),
                (Route<dynamic> route) => false,
              );
            } else if (Platform.isIOS) {
              Navigator.of(context).pushAndRemoveUntil(
                CupertinoPageRoute(
                  builder: (context) => const BottomNavAI(),
                ),
                (Route<dynamic> route) => false,
              );
            }
          }
        }
      },
    );
  }

  Widget emailReVerifyButton() {
    if (Platform.isAndroid) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onPressed: () async {
            final internetCheck = await InternetConnection().hasInternetAccess;
            if (internetCheck) {
              showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Text(
                      "Alert",
                      style: GoogleFonts.lato(),
                    ),
                    content: Text(
                      "A New verification link will be sent to your email address ${widget.email}",
                      style: GoogleFonts.lato(),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          "Okay",
                          style: GoogleFonts.lato(),
                        ),
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
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: Text(
                        'No Internet',
                        style: GoogleFonts.lato(),
                      ),
                      content: Text(
                        'Please check your internet connection',
                        style: GoogleFonts.lato(),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: Text(
                            'Okay',
                            style: GoogleFonts.lato(color: Colors.blue),
                          ),
                        ),
                      ],
                    );
                  });
            }
          },
          child: Text(
            'ReSend Email',
            style: GoogleFonts.lato(
              color: Colors.white,
            ),
          ),
        ),
      );
    } else if (Platform.isIOS) {
      return SizedBox(
        height: 50,
        width: double.infinity,
        child: CupertinoButton(
          color: CupertinoColors.activeBlue,
          onPressed: () async {
            final checkInternet = await InternetConnection().hasInternetAccess;
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
                        child: Text(
                          "Okay",
                          style: GoogleFonts.lato(),
                        ),
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
                    title: Text(
                      ' Alert',
                      style: GoogleFonts.lato(),
                    ),
                    content: Text(
                      'No Internet Connection Please check your internet connection and try again',
                      style: GoogleFonts.lato(),
                    ),
                    actions: [
                      CupertinoDialogAction(
                        child: Text(
                          "Okay",
                          style: GoogleFonts.lato(),
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
          },
          child: Text(
            'Resend Email',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget android() {
    return Scaffold(
      backgroundColor: Constants.screenBgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 30),
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
                        Icons.arrow_back,
                        size: 30,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer()
                ],
              ),
              Image.asset(
                height: 100,
                width: 100,
                !isVerified
                    ? 'assets/images/email.png'
                    : 'assets/images/verified.png',
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                'An Email link  sent to the mail id',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
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
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                !isVerified
                    ? 'Link is for verification of your Email'
                    : "Email Successfully Verified",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              !isVerified ? emailReVerifyButton() : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  Widget ios() {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Constants.screenBgColor,
          child: SafeArea(
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
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      height: 100,
                      width: 100,
                      !isVerified
                          ? 'assets/images/email.png'
                          : 'assets/images/verified.png',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'An Email link  sent to the mail id',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
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
                      !isVerified
                          ? 'Link is for verification of your Email'
                          : "Email Successfully Verified",
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: CupertinoColors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    !isVerified ? emailReVerifyButton() : const SizedBox()
                  ],
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
