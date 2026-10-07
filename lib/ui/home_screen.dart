import 'package:flutter/material.dart';
import 'tabs/workspace_tab.dart';
import 'tabs/tools_tab.dart';
import 'tabs/config_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _tabs = [const WorkspaceTab(), const ToolsTab(), const ConfigTab()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('墨境 AI OS 满血版', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.all(12), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: const Text('全功能激活', style: TextStyle(color: Colors.greenAccent, fontSize: 10)),
          )
        ],
      ),
      body: SafeArea(child: _tabs[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF18181B),
        selectedItemColor: const Color(0xFF38BDF8),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: '工作台 (多开)'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: '高阶工具'),
          BottomNavigationBarItem(icon: Icon(Icons.memory), label: 'AI团队与算力'),
        ],
      ),
    );
  }
}