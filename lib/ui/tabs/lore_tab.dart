import 'package:flutter/material.dart';

class LoreTab extends StatelessWidget {
  const LoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("世界观与记忆引擎"),
          bottom: const TabBar(
            indicatorColor: Color(0xFF2563EB), labelColor: Color(0xFF2563EB), unselectedLabelColor: Colors.grey,
            tabs: [Tab(text: "角色与禁忌"), Tab(text: "事实账本 (防吃书)")],
          ),
        ),
        body: TabBarView(
          children: [
            // 角色库页面
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCharCard('李昂 (主角)', '绝对理智 / 数据流 / 不近人情', '绝不会因为同情心泛滥而救人；必须在利益最大化时才出手。', true),
                const SizedBox(height: 12),
                _buildCharCard('机械神教', '反派组织 / 狂热崇拜', '认为血肉苦弱，试图将全城人类强制机械飞升。', false),
              ],
            ),
            // 事实账本页面
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text("AI 管家自动提取的时间线与资产状态", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 16),
                _buildFactRow('第 1 章', '获得物品', '破损的机械秒表', '当前生效中'),
                _buildFactRow('第 1 章', '身体状态', '生命倒计时 3 分钟', '待更新'),
                _buildFactRow('第 2 章', '结仇事件', '击杀神教底层教徒', '伏笔：将引来审判官'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCharCard(String name, String tags, String rules, bool isLocked) {
    return Card(
      child: Container(
        decoration: isLocked ? BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFFECACA))) : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [CircleAvatar(backgroundColor: Colors.black12, radius: 16, child: Text(name[0], style: const TextStyle(fontSize: 12))), const SizedBox(width: 8), Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
                if (isLocked) const Icon(Icons.lock, color: Color(0xFFDC2626), size: 16)
              ],
            ),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.05), borderRadius: BorderRadius.circular(8)), child: Text(tags, style: const TextStyle(fontSize: 11, color: Colors.black87))),
            const SizedBox(height: 12),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Icon(Icons.warning_amber, size: 14, color: Colors.redAccent), const SizedBox(width: 8), Expanded(child: Text("禁忌红线: $rules", style: TextStyle(fontSize: 12, color: isLocked ? const Color(0xFF991B1B) : Colors.grey)))])
          ],
        ),
      ),
    );
  }

  Widget _buildFactRow(String chapter, String type, String desc, String status) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 48, padding: const EdgeInsets.symmetric(vertical: 4), decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)), child: Center(child: Text(chapter, style: const TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(type, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ])),
          Text(status, style: const TextStyle(fontSize: 10, color: Color(0xFF10B981))),
        ],
      ),
    );
  }
}