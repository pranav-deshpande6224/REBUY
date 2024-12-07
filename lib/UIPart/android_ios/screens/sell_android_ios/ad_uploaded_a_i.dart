import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resell/constants/constants.dart';

class AdUploadedAI extends StatelessWidget {
  final String categoryName;
  const AdUploadedAI({required this.categoryName, super.key});

  Widget body(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 8,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Platform.isAndroid
                        ? Icons.check_circle_rounded
                        : Platform.isIOS
                            ? CupertinoIcons.check_mark_circled_solid
                            : Icons.photo,
                    color: Platform.isAndroid ? Colors.blue : null,
                    size: 100,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Your Ad Posted Successfully',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          button(context)
        ],
      ),
    );
  }

  Widget button(BuildContext context) {
    if (Platform.isAndroid) {
      return Expanded(
        flex: 2,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (categoryName == Constants.other) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Continue',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      );
    }
    if (Platform.isIOS) {
      return Expanded(
        flex: 2,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: CupertinoButton(
                color: CupertinoColors.activeBlue,
                child: Text(
                  'Continue',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                   if (categoryName == Constants.other) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget android(BuildContext context) {
    return Scaffold(
      body: body(context),
    );
  }

  Widget ios(BuildContext context) {
    return CupertinoPageScaffold(
      child: body(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return android(context);
    }
    if (Platform.isIOS) {
      return ios(context);
    }
    return const SizedBox();
  }
}
