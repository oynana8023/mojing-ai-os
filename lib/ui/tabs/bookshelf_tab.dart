import 'package:flutter/material.dart';

class BookshelfTab extends StatelessWidget {
  const BookshelfTab({super.key});

  void _showProjectCreator(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("🚀 AI 爆款立项剧场", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text("输入脑洞，市场主编将为你推演 3 套黄金三章方案", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(maxLines: 4, decoration: InputDecoration(hintText: '例：赛博修仙，电子木鱼...', filled: true, fillColor: const Color(0xFFF1F5F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 24),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("正在生成 3 套开书方案卡片...")));
            }, child: const Text("主编推演方案"))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("我的工作室"),
        actions: [IconButton(icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB), size: 32), onPressed: () => _showProjectCreator(context)), const SizedBox(width: 8)],
      ),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
        children: [
          Row(
            children: [
              Expanded(child: _buildBookCard('超维灵视：诡局调查员', '连载中', '24.5万', 0.8, const Color(0xFF10B981))),
              const SizedBox(width: 16),
              Expanded(child: _buildBookCard('机械飞升录', '大纲构建', '0字', 0.1, const Color(0xFFF59E0B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBookCard(String title, String status, String words, double progress, Color statusColor) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold))),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(words, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(width: 24, height: 24, child: CircularProgressIndicator(value: progress, strokeWidth: 3, backgroundColor: const Color(0xFFE2E8F0), color: const Color(0xFF2563EB))),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}