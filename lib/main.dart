import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/db_helper.dart';
import 'ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark,
  ));
  await DBHelper.instance.database; // 初始化13张底层表
  runApp(const MojingUltraApp());
}

class MojingUltraApp extends StatelessWidget {
  const MojingUltraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '墨境 AI OS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50 高级灰白
        textTheme: GoogleFonts.notoSansTextTheme(Theme.of(context).textTheme),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2563EB), secondary: Color(0xFF10B981),
          surface: Colors.white, error: Color(0xFFEF4444),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF8FAFC), elevation: 0,
          centerTitle: false, iconTheme: IconThemeData(color: Color(0xFF0F172A)),
          titleTextStyle: TextStyle(color: Color(0xFF0F172A), fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        ),
        cardTheme: CardTheme(
          color: Colors.white, elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white,
            elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}