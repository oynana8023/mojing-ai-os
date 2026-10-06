class SkillManager {
  async importSkill(url) {
    let cleanUrl = url.trim();
    if (cleanUrl.includes('github.com') && !cleanUrl.includes('raw.githubusercontent.com')) {
      cleanUrl = cleanUrl.replace('github.com', 'raw.githubusercontent.com').replace('/blob/', '/');
    }
    
    const res = await fetch(cleanUrl);
    if (!res.ok) throw new Error(`无法下载技能文件，HTTP 状态码: ${res.status}`);
    
    const text = await res.text();
    let newSkill;
    
    try {
      const parsed = JSON.parse(text);
      newSkill = {
        id: parsed.id || 'skill_' + Date.now(),
        name: parsed.name || '外部网络技能',
        category: parsed.category || '通用技巧',
        prompt: parsed.prompt || text,
        time: Date.now()
      };
    } catch {
      newSkill = {
        id: 'skill_' + Date.now(),
        name: '自定义纯文本提示词',
        category: '文本导入',
        prompt: text,
        time: Date.now()
      };
    }
    
    await window.novelDB.put('skills', newSkill);
    return newSkill;
  }
}

window.skillManager = new SkillManager();