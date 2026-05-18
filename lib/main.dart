import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'view/core/colors.dart';
import 'view/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CetakIn',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        fontFamily: GoogleFonts.hankenGrotesk().fontFamily,
        useMaterial3: true,
        textTheme: GoogleFonts.hankenGroteskTextTheme(),
      ),
      home: const HomePage(),
    );
  }
}
