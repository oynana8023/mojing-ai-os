import 'package:flutter/material.dart';
import 'core/db_helper.dart';
import 'ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.database; // 初始化超级数据库
  runApp(const MojingApp());
}

class MojingApp extends StatelessWidget {
  const MojingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '墨境 AI 工作室满血版',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF09090B),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF09090B), elevation: 0),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF38BDF8), surface: Color(0xFF18181B)),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}