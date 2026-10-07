import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../core/agent_director.dart';

class ChapterEditor extends StatefulWidget {
  final int projectId;
  final String globalOutline;
  const ChapterEditor({super.key, required this.projectId, required this.globalOutline});
  @override
  State<ChapterEditor> createState() => _ChapterEditorState();
}

class _ChapterEditorState extends State<ChapterEditor> {
  List<Map<String, dynamic>> _chapters = [];
  bool _isWorking = false;
  String _status = "待命";

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final c = await DBHelper.instance.queryWhere('chapters', 'project_id = ?', [widget.projectId]);
    setState(() => _chapters = c);
  }

  Future<void> _runPipeline() async {
    setState(() { _isWorking = true; _status = "【主笔】撰写初稿中..."; });
    try {
      final num = _chapters.length + 1;
      final ctx = _chapters.isEmpty ? "开局" : _chapters.last['memory_state'];
      
      final draft = await AgentDirector.writeChapter("第$num章", widget.globalOutline, ctx);
      setState(() => _status = "【审稿编辑】逻辑纠错与排雷中...");
      
      final qaReport = await AgentDirector.runQA(draft);
      setState(() => _status = "【读者模拟员】试读打分中...");
      
      final score = await AgentDirector.runReaderSim(draft);
      setState(() => _status = "【记忆管家】状态机提取中...");
      
      final memory = await AgentDirector.runMemory(draft);
      
      await DBHelper.instance.insert('chapters', {
        'project_id': widget.projectId,
        'chapter_num': num,
        'title': "第$num章",
        'content': draft,
        'qa_report': qaReport,
        'reader_score': score,
        'memory_state': memory
      });
      await _load();
      setState(() => _status = "全流程闭环完成！");
    } catch (e) {
      setState(() => _status = "异常: $e");
    } finally {
      setState(() => _isWorking = false);
    }
  }

  void _showQA(String content, String title) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: SelectableText(content)),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("关闭"))],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12), color: const Color(0xFF18181B),
          child: Row(
            children: [
              Expanded(child: Text("状态: $_status", style: const TextStyle(color: Colors.amber, fontSize: 12))),
              ElevatedButton(onPressed: _isWorking ? null : _runPipeline, child: const Text("续写一章 (走全管线)"))
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _chapters.length,
            itemBuilder: (ctx, i) {
              final c = _chapters[i];
              return ExpansionTile(
                title: Text(c['title']),
                subtitle: Text("追读评分: ${c['reader_score'].toString().split('\n')[0]}", style: const TextStyle(color: Colors.green)),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton.icon(onPressed: () => _showQA(c['qa_report'], "编辑质检报告"), icon: const Icon(Icons.grading, size: 16), label: const Text("审稿报告")),
                      TextButton.icon(onPressed: () => _showQA(c['memory_state'], "防吃书图谱"), icon: const Icon(Icons.memory, size: 16), label: const Text("因果记忆")),
                      TextButton.icon(onPressed: () => _showQA(c['reader_score'], "读者评价"), icon: const Icon(Icons.face, size: 16), label: const Text("读者评价")),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(16), margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: SelectableText(c['content'], style: const TextStyle(fontSize: 14, height: 1.6)),
                  ),
                  // 局部重写功能占位
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.auto_fix_high), label: const Text("局部锁定重写 / 扩写")),
                  )
                ],
              );
            },
          ),
        )
      ],
    );
  }
}