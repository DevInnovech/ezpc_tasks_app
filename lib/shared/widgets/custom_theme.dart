import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/theme/constraints.dart';

class MyTheme {
  static final borderRadius = BorderRadius.circular(10.0);
  static final theme = ThemeData(
      //brightness: Brightness.light,
      primaryColor: whiteColor,
      scaffoldBackgroundColor: scaffoldBgColor,
      // bottomSheetTheme: const BottomSheetThemeData(backgroundColor: whiteColor),
      // colorScheme: const ColorScheme.light(secondary: lightningYellowColor),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBgColor,
        centerTitle: true,
        titleTextStyle: GoogleFonts.workSans(
            color: blackColor, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: const IconThemeData(color: blackColor),
        elevation: 0,
      ),
      textTheme: GoogleFonts.workSansTextTheme(
        TextTheme(
          bodySmall: GoogleFonts.workSans(
              fontSize: 12, height: 1.83, fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.workSans(
              fontSize: 16, fontWeight: FontWeight.w500, height: 1.375),
          bodyMedium: GoogleFonts.workSans(fontSize: 14, height: 1.5714),
          labelLarge: GoogleFonts.workSans(
              fontSize: 16, height: 2, fontWeight: FontWeight.w600),
          titleLarge: GoogleFonts.workSans(
              fontSize: 16, height: 2, fontWeight: FontWeight.w600),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 64),
          backgroundColor: whiteColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
        ),
      ),
      textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
            shadowColor: WidgetStatePropertyAll(transparent),
            elevation: WidgetStatePropertyAll(0.0),
            iconSize: WidgetStatePropertyAll(20.0),
            splashFactory: NoSplash.splashFactory,
            overlayColor: WidgetStatePropertyAll(
              (transparent),
            ),
            padding: WidgetStatePropertyAll(EdgeInsets.zero)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        elevation: 3,
        backgroundColor: Color(0x00ffffff),
        showUnselectedLabels: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        hintStyle: GoogleFonts.workSans(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
          color: grayColor,
        ),
        labelStyle: GoogleFonts.workSans(
          fontWeight: FontWeight.w500,
          fontSize: 16.0,
          color: hintTextColor,
        ),
        //contentPadding: Utils.symmetric(h: ),
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: primaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        fillColor: whiteColor,
        //fillColor: fillColor,
        filled: true,
        focusColor: primaryColor,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: blackColor,
        selectionColor: blackColor,
        selectionHandleColor: blackColor,
      ),
      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: primaryColor));
}
