import 'package:flutter/material.dart';
import '../../core/db_helper.dart';
import '../../core/api_engine.dart';
import '../../core/agent_director.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});
  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  final _keyCtrl = TextEditingController();
  List<Map<String, dynamic>> _providers = [];
  Map<String, Map<String, dynamic>> _assigns = {};
  bool _isLoading = false;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await DBHelper.instance.queryAll('providers');
    final a = await DBHelper.instance.queryAll('assignments');
    final map = <String, Map<String, dynamic>>{};
    for (var x in a) { map[x['role_key']] = x; }
    setState(() { _providers = p; _assigns = map; });
  }

  Future<void> _batchAdd() async {
    if (_keyCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    final lines = _keyCtrl.text.split('\n');
    for (var l in lines) {
      if (!l.contains(':')) continue;
      final parts = l.split(':');
      final type = parts[0].trim().toLowerCase();
      final key = parts.sublist(1).join(':').trim();
      try {
        final models = await ApiEngine.fetchModels(type, key);
        await DBHelper.instance.insert('providers', {'id': 'p_${DateTime.now().millisecondsSinceEpoch}', 'type': type, 'api_key': key, 'models_json': models.toString()});
      } catch (e) { debugPrint(e.toString()); }
    }
    _keyCtrl.clear();
    await _load();
    setState(() => _isLoading = false);
  }

  Future<void> _autoAssign() async {
    if (_providers.isEmpty) return;
    final p = _providers.first; 
    for (var role in AgentDirector.roles.keys) {
      await DBHelper.instance.insert('assignments', {'role_key': role, 'provider_id': p['id'], 'model_id': p['type'] == 'siliconflow' ? 'Qwen/Qwen2.5-7B-Instruct' : 'auto'});
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("工作室基建配置", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("1. 录入全网 API", style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(controller: _keyCtrl, maxLines: 3, decoration: const InputDecoration(hintText: 'siliconflow: sk-...\ndeepseek: sk-...', filled: true, fillColor: Colors.black26)),
              const SizedBox(height: 8),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _isLoading ? null : _batchAdd, child: const Text("并发嗅探全网免费模型"))),
              Text("已接入节点数: ${_providers.length}", style: const TextStyle(color: Colors.grey, fontSize: 12))
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("2. 智能体 HR 自动排班", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: _autoAssign, child: const Text("⚡ 自动分配"))
                ],
              ),
              ...AgentDirector.roles.entries.map((e) {
                final cur = _assigns[e.key];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text("${e.value}: ${cur != null ? cur['model_id'] : '未指派'}", style: const TextStyle(fontSize: 12)),
                );
              }),
            ],
          ),
        )
      ],
    );
  }
}