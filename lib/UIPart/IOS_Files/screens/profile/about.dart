import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'About',
          style: GoogleFonts.roboto(),
        ),
      ),
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 15,
        ),
        child: Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(width: 0.5),
          ),
          child: Column(
            children: [
              Text(
                "Builted by ",
                style: GoogleFonts.roboto(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              
              Text('Pranav Deshpande')
            ],
          ),
        ),
      )),
    );
  }
}
