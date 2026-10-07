import 'package:flutter/material.dart';
import 'lore_manager.dart';
import 'chapter_editor.dart';
import 'market_dashboard.dart';
import 'export_manager.dart';

class ProjectDashboard extends StatelessWidget {
  final Map<String, dynamic> project;
  const ProjectDashboard({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(project['title'], style: const TextStyle(fontSize: 16)),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: Color(0xFF38BDF8),
            tabs: [
              Tab(text: "📚 设定与伏笔 (Lore)"),
              Tab(text: "✍️ 断点工作台 (Editor)"),
              Tab(text: "📈 商业数据与优化"),
              Tab(text: "📤 IP 裂变与合规导出"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            LoreManager(projectId: project['id']),
            ChapterEditor(projectId: project['id'], globalOutline: project['global_outline'] ?? ''),
            MarketDashboard(projectId: project['id']),
            ExportManager(project: project),
          ],
        ),
      ),
    );
  }
}