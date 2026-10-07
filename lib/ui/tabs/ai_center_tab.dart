import 'package:flutter/material.dart';

class AiCenterTab extends StatelessWidget {
  const AiCenterTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("底层算力监控室")),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
        children: [
          // 顶级算力仪表盘
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(20)),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.token, color: Colors.white70), SizedBox(height: 12),
                    Text("今日 Token 吞吐", style: TextStyle(color: Colors.white70, fontSize: 12)),
                    SizedBox(height: 4), Text("125.4 K", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.attach_money, color: Color(0xFF10B981)), SizedBox(height: 12),
                    Text("预估 API 账单", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    SizedBox(height: 4), Text("¥ 0.00", style: TextStyle(color: Color(0xFF0F172A), fontSize: 24, fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text("算力节点库 (Node Pools)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildNodeCard("SiliconFlow", "国内极速节点 · 免费池生效中", true),
          _buildNodeCard("DeepSeek", "深度推理节点 · 额度 ¥14.0", true),
          Container(
            width: double.infinity, margin: const EdgeInsets.symmetric(vertical: 8),
            child: OutlinedButton.icon(icon: const Icon(Icons.add), label: const Text("录入新厂商 API / 本地 Ollama"), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), side: const BorderSide(color: Color(0xFFE2E8F0), style: BorderStyle.solid)), onPressed: (){}),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("工作室岗位排班表 (HR)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton(onPressed: (){}, child: const Text("⚡ 智能路由分配"))
            ],
          ),
          const SizedBox(height: 8),
          _buildAgentDesk("市场主编", "GLM-4-Flash", "商业逻辑 / 高级立项", true),
          _buildAgentDesk("金牌写手", "Qwen2.5-7B-Instruct", "零成本量产 / 极速", true),
          _buildAgentDesk("审稿编辑", "DeepSeek-V2", "精准除错 / 去 AI 味", true),
          _buildAgentDesk("读者模拟器", "未挂载模型", "点击分配算力资源", false),
        ],
      ),
    );
  }

  Widget _buildNodeCard(String name, String status, bool isHealthy) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.dns, color: Color(0xFF2563EB))),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Icon(Icons.circle, size: 12, color: isHealthy ? const Color(0xFF10B981) : Colors.redAccent),
      ),
    );
  }

  Widget _buildAgentDesk(String role, String model, String desc, bool isOnline) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: isOnline ? const Color(0xFF10B981) : Colors.grey, boxShadow: isOnline ? [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.5), blurRadius: 6, spreadRadius: 2)] : [])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(role, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              Row(children: [const Icon(Icons.smart_toy, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(model, style: TextStyle(color: isOnline ? const Color(0xFF2563EB) : Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold))]),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ])),
            const Icon(Icons.drag_indicator, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}