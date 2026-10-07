import 'package:flutter/material.dart';

class DeskTab extends StatelessWidget {
  const DeskTab({super.key});

  void _showAiTools(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(24)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Icon(Icons.auto_fix_high, color: Colors.amber), title: const Text("呼叫主笔续写", style: TextStyle(color: Colors.white)), subtitle: const Text("基于大纲自动生成后续 2000 字", style: TextStyle(color: Colors.grey, fontSize: 12)), onTap: (){}),
            ListTile(leading: const Icon(Icons.cleaning_services, color: Colors.green), title: const Text("一键去 AI 味", style: TextStyle(color: Colors.white)), subtitle: const Text("消除废话与机械句式", style: TextStyle(color: Colors.grey, fontSize: 12)), onTap: (){}),
            ListTile(leading: const Icon(Icons.checklist, color: Colors.blue), title: const Text("审稿质检分析", style: TextStyle(color: Colors.white)), subtitle: const Text("排查毒点、逻辑漏洞与违禁词", style: TextStyle(color: Colors.grey, fontSize: 12)), onTap: (){}),
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("第 1 章：血月降临", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("已存草稿 · 2104 字", style: TextStyle(fontSize: 10, color: Colors.grey)),
        ]),
        actions: [IconButton(icon: const Icon(Icons.history), onPressed: (){}), IconButton(icon: const Icon(Icons.list), onPressed: (){})],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 120),
            children: const [
              Text("    那是一轮违背了天体物理学常识的红月。\n\n    李昂站在废弃的瞭望塔上，手中的机械秒表发出轻微的咔哒声。毒雾在下方的街道弥漫，那些曾经被称为人类的生物，此刻正发出令人牙酸的骨骼摩擦声。\n\n    “系统，校准环境威胁指数。”他在心底默念。\n\n    【滴——环境污染度 98%，警告：请立即寻找掩体！】\n\n    李昂没有动，他看着手腕上倒计时仅剩 3 分钟的生命刻度，嘴角扯出一个难看的弧度。与其等死，不如在这个疯狂的世界里，杀出一条血路。", 
                style: TextStyle(fontSize: 18, height: 1.8, color: Color(0xFF334155), fontFamily: 'serif')),
              SizedBox(height: 24),
              // 模拟审稿 AI 质检波浪线反馈
              Text("    [编辑 AI 质检建议：末尾‘杀出一条血路’过于套路化，建议修改为更符合理智型男主心理活动的冷酷描写。]", style: TextStyle(color: Colors.orange, fontSize: 12, fontStyle: FontStyle.italic)),
            ],
          ),
          // 悬浮 AI 操作岛
          Positioned(
            bottom: 100, left: 60, right: 60,
            child: Material(
              elevation: 10, shadowColor: Colors.black26, borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () => _showAiTools(context), borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(30)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.graphic_eq, color: Colors.white, size: 18), SizedBox(width: 8), Text("唤醒 AI 创作助理", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}