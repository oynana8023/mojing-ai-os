import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../core/agent_director.dart';
import '../pages/project_dashboard.dart';

class WorkspaceTab extends StatefulWidget {
  const WorkspaceTab({super.key});
  @override
  State<WorkspaceTab> createState() => _WorkspaceTabState();
}

class _WorkspaceTabState extends State<WorkspaceTab> {
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = false;
  final _ideaCtrl = TextEditingController();

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final data = await DBHelper.instance.queryAll('projects');
    setState(() => _projects = data.reversed.toList());
  }

  void _createNew() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: const Color(0xFF18181B), builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🚀 一键爆款立项", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(controller: _ideaCtrl, maxLines: 3, decoration: const InputDecoration(hintText: '输入脑洞/金手指/目标群体...', filled: true, fillColor: Colors.black26)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = true);
                  try {
                    final market = await AgentDirector.runMarket(_ideaCtrl.text, "男频/女频通用", "全网读者");
                    final outline = await AgentDirector.runOutline(market);
                    await DBHelper.instance.insert('projects', {
                      'title': '新脑洞项目 ${DateTime.now().second}',
                      'genre': '未分类',
                      'market_plan': market,
                      'global_outline': outline,
                    });
                    _ideaCtrl.clear();
                    await _load();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("立项失败: $e")));
                  } finally {
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text("生成商业大纲与世界观"),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading) const LinearProgressIndicator(),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("我的沙盒宇宙", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(onPressed: _isLoading ? null : _createNew, icon: const Icon(Icons.add, size: 16), label: const Text("新开书"))
            ],
          ),
        ),
        Expanded(
          child: _projects.isEmpty 
            ? const Center(child: Text("暂无项目，点击上方新建开书", style: TextStyle(color: Colors.grey)))
            : ListView.builder(
            itemCount: _projects.length,
            itemBuilder: (ctx, i) {
              final p = _projects[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: const Color(0xFF18181B),
                child: ListTile(
                  title: Text(p['title'], style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF38BDF8))),
                  subtitle: const Text("点击进入完整管理面板 (世界观/创作台/数据/导出)"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      await DBHelper.instance.delete('projects', 'id', p['id']);
                      _load();
                    },
                  ),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectDashboard(project: p))),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}