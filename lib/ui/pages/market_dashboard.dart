import 'package:flutter/material.dart';

class MarketDashboard extends StatelessWidget {
  final int projectId;
  const MarketDashboard({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("商业数据回流中心", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Card(
          color: const Color(0xFF18181B),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("录入真实平台数据", style: TextStyle(color: Colors.amber)),
                const SizedBox(height: 8),
                const TextField(decoration: InputDecoration(hintText: '今日追读率 (如 45%)', filled: true, fillColor: Colors.black26)),
                const SizedBox(height: 8),
                const TextField(maxLines: 3, decoration: InputDecoration(hintText: '读者最新评论 (用于情感分析)', filled: true, fillColor: Colors.black26)),
                const SizedBox(height: 8),
                SizedBox(width: double.infinity, child: ElevatedButton(onPressed: (){}, child: const Text("分析数据并生成大纲修正方案")))
              ],
            ),
          ),
        )
      ],
    );
  }
}