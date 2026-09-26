import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );
}