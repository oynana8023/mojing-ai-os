import 'api_engine.dart';
import 'db_helper.dart';

class AgentDirector {
  static final Map<String, String> roles = {
    'CHIEF_EDITOR': '市场主编 (立项与商业优化)',
    'ARCHITECT': '大纲设定师 (世界观与伏笔)',
    'SCRIBE': '金牌写手 (长文案量产)',
    'POLISHER': '润色改写师 (选段精修)',
    'QA_EDITOR': '审稿编辑 (逻辑纠错与合规)',
    'READER_SIM': '读者模拟员 (追读预判)',
    'MEMORY_KEEPER': '记忆管家 (状态机防吃书)',
    'ADAPTER': '衍生改编员 (剧本/漫画生成)'
  };

  static Future<Map<String, dynamic>> _getWorker(String roleKey) async {
    final assigns = await DBHelper.instance.queryAll('assignments');
    final worker = assigns.firstWhere((e) => e['role_key'] == roleKey, orElse: () => {});
    if (worker.isEmpty) throw Exception("请先去【配置页】为 [${roles[roleKey]}] 指派模型！");
    final provs = await DBHelper.instance.queryAll('providers');
    final p = provs.firstWhere((e) => e['id'] == worker['provider_id'], orElse: () => {});
    return {'pType': p['type'], 'key': p['api_key'], 'mId': worker['model_id']};
  }

  static Future<String> runMarket(String idea, String genre, String target) async {
    final w = await _getWorker('CHIEF_EDITOR');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "网文主编。灵感:$idea 题材:$genre 目标群体:$target。输出: 1.书名方案 2.爆款简介 3.受众痛点分析 4.黄金三章大纲。"}
    ]);
  }

  static Future<String> runOutline(String plan) async {
    final w = await _getWorker('ARCHITECT');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "大纲师。基于立项:\n$plan\n输出: 1.详细力量体系 2.核心人物卡(锁定性格防OOC) 3.前10章情节推演(标注伏笔位置)。"}
    ]);
  }

  static Future<String> writeChapter(String title, String outline, String loreContext) async {
    final w = await _getWorker('SCRIBE');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "金牌写手。要求: 强动作白描，避免AI味词汇。\n【世界观与前文状态】:$loreContext\n【大纲】:$outline\n写《$title》正文(约2000字):"}
    ]);
  }

  static Future<String> rewriteSelection(String text, String instruction) async {
    final w = await _getWorker('POLISHER');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "润色师。根据指令:[$instruction]，重写以下段落:\n$text"}
    ]);
  }

  static Future<String> runQA(String draft) async {
    final w = await _getWorker('QA_EDITOR');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "审稿质检。检查以下正文的: 1.逻辑漏洞 2.重复水词 3.人设崩塌 4.敏感合规风险。给出结构化修改建议:\n$draft"}
    ]);
  }

  static Future<String> runReaderSim(String draft) async {
    final w = await _getWorker('READER_SIM');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "老白读者模拟。试读此章:\n$draft\n评价: 1.哪里毒/劝退? 2.章末钩子能勾住人吗? 3.预估追读率打分(0-100)。"}
    ]);
  }

  static Future<String> runMemory(String draft) async {
    final w = await _getWorker('MEMORY_KEEPER');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "记忆管家。提取结构化状态用于防吃书: 1.时间线 2.物理位置 3.人物好感度/仇恨 4.消耗/获得的道具 5.新增伏笔。原文:\n$draft"}
    ]);
  }
  
  static Future<String> runAdapter(String content, String targetFormat) async {
    final w = await _getWorker('ADAPTER');
    return await ApiEngine.chat(pType: w['pType'], apiKey: w['key'], modelId: w['mId'], messages: [
      {'role':'user', 'content': "衍生改编员。将以下小说内容改编为【$targetFormat】格式（如短剧分镜、漫画脚本、有声演播提示）:\n$content"}
    ]);
  }
}