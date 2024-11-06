import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:life_link/constants/colors.dart';

class FontStyles {
  static TextStyle boldTextFieldStyle() {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        color: Colors.black,
        fontSize: 25,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static TextStyle headLIneTextFieldStyle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(color: kOrangeColor, fontSize: 25.0),
    );
  }

  static TextStyle lightTextFieldStyle() {
    return GoogleFonts.poppins(
      textStyle: TextStyle(
          color: Colors.black38, fontSize: 15.0, fontWeight: FontWeight.w600),
    );
  }

  static TextStyle semiboldTextFieldStyle() {
    return GoogleFonts.notoSans(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static TextStyle hintTextFieldStyle() {
    return GoogleFonts.notoSans(
      textStyle: TextStyle(
        color: Colors.grey,
        fontSize: 18.0,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
