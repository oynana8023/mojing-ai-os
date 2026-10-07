import 'package:flutter/material.dart';

class ToolsTab extends StatelessWidget {
  const ToolsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("全网通用高阶工具箱", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF18181B),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("🔍 爆款逆向拆书引擎", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const TextField(decoration: InputDecoration(hintText: '输入爆款书名或粘贴前三章原文...', filled: true, fillColor: Colors.black26)),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){}, child: const Text("拆解金手指与黄金三章结构"))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}