import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataTab extends StatelessWidget {
  const DataTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("商业数据与诊断面板")),
      body: ListView(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 100),
        children: [
          const Text("读者模拟团试读报告 (多画像交叉分析)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFF0F172A),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _buildLegend("男频老白", const Color(0xFF38BDF8)), const SizedBox(width: 16),
                    _buildLegend("女频读者", const Color(0xFFF472B6)), const SizedBox(width: 16),
                    _buildLegend("下沉市场", const Color(0xFF34D399)),
                  ]),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 220,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon, tickCount: 4, ticksTextStyle: const TextStyle(color: Colors.transparent),
                        gridBorderData: const BorderSide(color: Color(0xFF334155)),
                        radarBorderData: const BorderSide(color: Colors.transparent),
                        titlePositionPercentageOffset: 0.1,
                        getTitle: (index, angle) => RadarChartTitle(text: ['爽点密度', '脑洞创意', '文笔细腻', '剧情节奏', '毒点排雷', '情绪价值'][index], textStyle: const TextStyle(fontSize: 10, color: Colors.white70)),
                        dataSets: [
                          RadarDataSet(fillColor: const Color(0xFF38BDF8).withOpacity(0.3), borderColor: const Color(0xFF38BDF8), entryRadius: 2, dataEntries: const [RadarEntry(value: 5), RadarEntry(value: 4), RadarEntry(value: 3), RadarEntry(value: 5), RadarEntry(value: 4), RadarEntry(value: 3)]),
                          RadarDataSet(fillColor: const Color(0xFFF472B6).withOpacity(0.3), borderColor: const Color(0xFFF472B6), entryRadius: 2, dataEntries: const [RadarEntry(value: 2), RadarEntry(value: 3), RadarEntry(value: 5), RadarEntry(value: 3), RadarEntry(value: 2), RadarEntry(value: 5)]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("诊断：本书极度契合硬核男频，但对女性读者劝退严重。建议无需修改，锁定目标受众群。", style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.5)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text("全书情绪张力曲线 (防节奏拖沓)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false), borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: const [FlSpot(1, 2), FlSpot(2, 2.5), FlSpot(3, 4), FlSpot(4, 3), FlSpot(5, 8), FlSpot(6, 10), FlSpot(7, 4)],
                            isCurved: true, curveSmoothness: 0.4,
                            color: const Color(0xFFEF4444), barWidth: 3, isStrokeCapRound: true,
                            belowBarData: BarAreaData(show: true, color: const Color(0xFFEF4444).withOpacity(0.1)),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("警告：前3章情绪铺垫过平，缺乏爆点，建议在第2章前置核心金手指以拉升曲线。", style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(icon: const Icon(Icons.outbox), label: const Text("打开全渠道 IP 导出终端"), onPressed: (){})
        ],
      ),
    );
  }

  Widget _buildLegend(String text, Color color) {
    return Row(children: [Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 4), Text(text, style: const TextStyle(color: Colors.white, fontSize: 10))]);
  }
}