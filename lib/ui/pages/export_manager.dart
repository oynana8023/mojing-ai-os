import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../core/agent_director.dart';

class ExportManager extends StatelessWidget {
  final Map<String, dynamic> project;
  const ExportManager({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("全渠道分发与版权合规", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ListTile(
          tileColor: const Color(0xFF18181B),
          leading: const Icon(Icons.book, color: Colors.blue),
          title: const Text("标准小说稿件导出 (.md)"),
          subtitle: const Text("包含大纲、设定集与全部正文"),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: const Color(0xFF18181B),
          leading: const Icon(Icons.video_camera_back, color: Colors.orange),
          title: const Text("全自动短剧脚本转化"),
          subtitle: const Text("呼叫【衍生改编员】生成短剧分镜表"),
          onTap: () {},
        ),
        const SizedBox(height: 8),
        ListTile(
          tileColor: const Color(0xFF18181B),
          leading: const Icon(Icons.mic, color: Colors.purple),
          title: const Text("有声演播台本转化"),
          subtitle: const Text("标注角色情绪与音效提示"),
          onTap: () {},
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: Colors.redAccent), borderRadius: BorderRadius.circular(8)),
          child: const Text("合规提示：导出前系统将自动进行敏感词扫描与融梗/抄袭风险自测，保护您的原创版权。", style: TextStyle(color: Colors.redAccent, fontSize: 12)),
        )
      ],
    );
  }
}