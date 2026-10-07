import 'package:flutter/material.dart';
import 'dart:ui';
import 'tabs/bookshelf_tab.dart';
import 'tabs/desk_tab.dart';
import 'tabs/lore_tab.dart';
import 'tabs/ai_center_tab.dart';
import 'tabs/data_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [const BookshelfTab(), const DeskTab(), const LoreTab(), const DataTab(), const AiCenterTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            backgroundColor: Colors.white.withOpacity(0.8),
            selectedItemColor: const Color(0xFF2563EB),
            unselectedItemColor: const Color(0xFF94A3B8),
            type: BottomNavigationBarType.fixed,
            elevation: 0, selectedFontSize: 10, unselectedFontSize: 10,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.library_books_rounded), label: '书架'),
              BottomNavigationBarItem(icon: Icon(Icons.draw_rounded), label: '写作台'),
              BottomNavigationBarItem(icon: Icon(Icons.hub_rounded), label: '设定库'),
              BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: '数据'),
              BottomNavigationBarItem(icon: Icon(Icons.memory_rounded), label: '算力'),
            ],
          ),
        ),
      ),
    );
  }
}