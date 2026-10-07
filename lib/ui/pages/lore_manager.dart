import 'package:flutter/material.dart';
import '../../core/db_helper.dart';

class LoreManager extends StatefulWidget {
  final int projectId;
  const LoreManager({super.key, required this.projectId});
  @override
  State<LoreManager> createState() => _LoreManagerState();
}

class _LoreManagerState extends State<LoreManager> {
  List<Map<String, dynamic>> _entities = [];

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final data = await DBHelper.instance.queryWhere('lore_entities', 'project_id = ?', [widget.projectId]);
    setState(() => _entities = data);
  }

  void _addEntity() {
    // 简化添加流程
    DBHelper.instance.insert('lore_entities', {
      'project_id': widget.projectId,
      'type': 'CHARACTER',
      'name': '新角色/新设定',
      'description': '描述信息',
      'rules': '绝对禁忌与性格(防OOC)'
    }).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("世界观字典 (防崩盘引擎)", style: TextStyle(fontWeight: FontWeight.bold)),
              ElevatedButton(onPressed: _addEntity, child: const Text("添加人物/伏笔/法宝"))
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _entities.length,
            itemBuilder: (ctx, i) {
              final e = _entities[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: const Color(0xFF18181B),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: Colors.blueGrey, child: Text(e['type'].substring(0,1))),
                  title: Text(e['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${e['description']}\n禁忌: ${e['rules'] ?? '无'}"),
                  trailing: IconButton(icon: const Icon(Icons.delete, size: 16), onPressed: () async {
                    await DBHelper.instance.delete('lore_entities', 'id', e['id']);
                    _load();
                  }),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}