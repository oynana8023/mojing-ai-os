class AgentDirector {
  constructor() {
    this.roles = {
      MARKET_ANALYST: '市场主编 (立项与爆款拆解)',
      ARCHITECT: '大纲构架师 (系统设定与分卷纲)',
      SCRIBE: '金牌主笔 (具体章节写作)',
      DE_AI_EDITOR: '修罗场审稿 (专门处理去AI味)',
      GUARDIAN: '长篇记忆守卫 (提炼动态因果摘要)'
    };
  }

  selectWorker(role, assignments) {
    if (assignments[role] && assignments[role].modelId) return assignments[role];
    const all = Object.values(assignments).filter(a => a && a.modelId);
    if (all.length > 0) return all[0];
    throw new Error(`系统尚未为【${this.roles[role]}】指派可用大模型，请点击配置页的【重新计算最优配置】。`);
  }

  async step1_MarketIdeation(idea, genre, worker, providers, log) {
    log('市场主编', `指派 [${worker.modelId}] 执行题材商业剖析...`);
    const prompt = `你是拥有15年经验的网文主编。作者灵感：“${idea}”，定位题材：“${genre}”。
请输出严密的商业化文案：
1. 【核心卖点提炼】
2. 【3个高转化率的书名建议】
3. 【霸气吸睛的简介方案】
4. 【黄金前三章的剧情推进节奏】
要求：杜绝自嗨，严格面向读者爽点。`;
    return await window.modelGateway.chatCompletion({ providerConfig: providers[worker.providerId], modelId: worker.modelId, messages: [{ role: 'user', content: prompt }] });
  }

  async step2_WorldAndOutline(marketPlan, totalChapters, worker, providers, log) {
    log('大纲构架师', `指派 [${worker.modelId}] 推演力量体系与多级大纲...`);
    const prompt = `根据如下商业立项书：\n${marketPlan}\n
请严格产出：
1. 【力量体系与等级限制】：不可崩盘的升级阶梯。
2. 【核心角色卡】：主角与大反派的性格、动机与绝对弱点。
3. 【前 ${totalChapters} 章分章细纲】：清楚标明每章的【出场人物】、【核心冲突点】、【章末钩子】。`;
    return await window.modelGateway.chatCompletion({ providerConfig: providers[worker.providerId], modelId: worker.modelId, messages: [{ role: 'user', content: prompt }] });
  }

  async step3_WriteChapter(chapTitle, outlineText, contextSummary, skillsPrompt, worker, providers, log) {
    log('金牌主笔', `指派 [${worker.modelId}] 执笔正文：【${chapTitle}】...`);
    const prompt = `你是一名文笔绝佳、极度擅长节奏控制的白金写手。
【长期设定的铁律指导】：${skillsPrompt}
【前文记忆摘要，绝对不可吃书】：${contextSummary}

本章写作任务：根据以下大纲，撰写【${chapTitle}】的正文内容。
【本章细纲】：${outlineText}

输出硬性要求：
1. 聚焦于动作、五感、微表情，避免空洞的叙述。
2. 语言必须符合人物性格和身份立场。
3. 直接输出 2000 字左右的正文，禁止任何开场白或解释。`;
    return await window.modelGateway.chatCompletion({ providerConfig: providers[worker.providerId], modelId: worker.modelId, messages: [{ role: 'user', content: prompt }] });
  }

  async step4_DeAI(rawContent, worker, providers, log) {
    log('修罗场审稿', `指派 [${worker.modelId}] 拦截初稿并执行高压去AI味...`);
    const prompt = `你是一个冷血无情的网文老编辑，你的任务是把大模型写出的初稿狠狠地“洗去AI恶臭味”。
任务清单：
1. 彻底删除“嘴角勾起一抹笑容”、“倒吸一口凉气”、“眼中闪过精芒”、“不知为何”、“总而言之”等一切AI高频机械词汇。
2. 将生硬的情感转折，改为真实的细节和动作白描。
3. 保留所有的原始情节发展，一丁点都不能改动主线。

待洗初稿如下：\n${rawContent}\n
直接给出经过高维精修后的成品正文。`;
    return await window.modelGateway.chatCompletion({ providerConfig: providers[worker.providerId], modelId: worker.modelId, messages: [{ role: 'user', content: prompt }] });
  }

  async extractSummary(content, worker, providers, log) {
    log('记忆守卫', `指派 [${worker.modelId}] 提炼关键事件与伏笔更新到记忆库...`);
    const prompt = `请用最多 150 字，极简总结以下剧情文本的关键事件，以便作为下一章的背景记忆。
必须包含三个要素：1. 发生了什么事。 2. 主角获得了什么道具/招惹了谁。 3. 留下了什么悬念钩子。
正文：\n${content.substring(0, 2000)}`;
    return await window.modelGateway.chatCompletion({ providerConfig: providers[worker.providerId], modelId: worker.modelId, messages: [{ role: 'user', content: prompt }] });
  }

  async analyzeBestseller(bookName, text, worker, providers) {
    const prompt = `你是一个身经百战的网文拆书专家。深度解剖爆款小说《${bookName}》${text ? '的参考原文片段：\n'+text : ''}。
请强制输出一份结构化拆解报告：
1. 【底层逻辑与金手指】(它赢在什么机制上，爽感来源是什么)
2. 【黄金三章模型拆解】(第一章做铺垫..第二章引爆点..第三章拉仇恨..)
3. 【人设与驱动力】(主角是极道流还是苟道流？核心行动目标是什么)
4. 【期待感设计】(作者是如何布置悬念勾着读者往下看的)
直入主题，禁止说废话。`;
    return await window.modelGateway.chatCompletion({ providerConfig: providers[worker.providerId], modelId: worker.modelId, messages: [{ role: 'user', content: prompt }] });
  }

  async standaloneDeAI(rawText, style, worker, providers) {
    const rules = {
      "克制平实": "句子必须剪短利落。剥离主观感受，用人物的具体动作（如摸刀、停顿）代替心理描写。",
      "网文爽感": "提升情绪烈度。主角的果决要被突出，反派面对打脸时必须有阶梯式的心理震慑反馈，不啰嗦直接碾压。",
      "古言细腻": "引入具体的视觉色彩、周遭冷暖与环境气味的描写。衣着配饰要贴合身份，心理活动需婉转且带有一丝留白。"
    };
    const prompt = `重写以下文本，彻底消除市面上常见的AI大模型写网文的机械感。
【你的风格锚点必须是】：${rules[style]}
【待精修的粗糙文本】：\n${rawText}\n
直接输出带有强大人味和感情的重写文本。`;
    return await window.modelGateway.chatCompletion({ providerConfig: providers[worker.providerId], modelId: worker.modelId, messages: [{ role: 'user', content: prompt }] });
  }
}

window.agentDirector = new AgentDirector();