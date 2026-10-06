class NovelApp {
  constructor() { 
    this.providers = {}; 
    this.assignments = {}; 
  }

  async init() {
    // 1. 绝对第一优先级：绑定界面UI！不论数据库死没死，确保按钮能点
    try {
      this.setupUI();
    } catch(e) {
      console.error("UI绑定异常:", e);
    }

    // 2. 监听数据库降级事件（容灾）
    window.addEventListener('db-fallback', (e) => {
      this.showError(`手机浏览器限制了存储权限，系统已自动降级为【临时内存模式】。\n在此模式下可正常体验，但⚠️刷新网页会导致未导出的进度丢失！\n(排查建议: 尝试更换Chrome浏览器或关闭浏览器的无痕安全模式)`);
    });

    // 3. 异步启动数据引擎（哪怕挂起也不会阻塞UI了）
    try {
      await window.novelDB.init();
      await this.loadProviders();
      await this.renderChapters();
      await this.renderSkills();
    } catch (err) {
      this.showError("数据加载出现严重故障: " + err.message);
    }
  }

  showError(msg) {
    const errBox = document.getElementById('global-error-console');
    const errText = document.getElementById('global-error-text');
    if(errBox && errText) {
      errBox.classList.remove('hidden');
      errText.innerText += `[系统警报] ${msg}\n\n`;
    }
  }

  async loadProviders() {
    const list = await window.novelDB.getAll('providers');
    this.providers = {};
    list.forEach(p => { this.providers[p.id] = p; });
    const assignData = await window.novelDB.get('projects', 'assignments');
    this.assignments = assignData ? assignData.value : {};
    this.renderProviders();
  }

  setupUI() {
    // 底部导航栏切换
    const tabs = document.querySelectorAll('[data-tab-btn]');
    for(let i=0; i<tabs.length; i++) {
      tabs[i].addEventListener('click', e => {
        const tab = e.currentTarget.getAttribute('data-tab-btn');
        
        const contents = document.querySelectorAll('.tab-content');
        for(let j=0; j<contents.length; j++) contents[j].classList.add('hidden');
        
        const targetTab = document.getElementById(`tab-${tab}`);
        if(targetTab) targetTab.classList.remove('hidden');
        
        for(let j=0; j<tabs.length; j++) {
          const tBtn = tabs[j].getAttribute('data-tab-btn');
          if (tBtn === tab) {
            tabs[j].classList.add('text-zinc-100');
            tabs[j].classList.remove('text-zinc-500');
          } else {
            tabs[j].classList.remove('text-zinc-100');
            tabs[j].classList.add('text-zinc-500');
          }
        }
      });
    }

    const bind = (id, event, handler) => {
      const el = document.getElementById(id);
      if (el) el.addEventListener(event, handler);
    };

    bind('btn-batch-add', 'click', () => this.handleBatchAddProviders());
    bind('btn-refresh-all', 'click', () => this.handleRefreshAllFreePools());
    bind('btn-smart-assign', 'click', () => this.handleSmartAssign(true));
    bind('btn-import-skill', 'click', () => this.handleImportSkill());
    bind('btn-deconstruct', 'click', () => this.handleDeconstruct());
    bind('btn-run-deai', 'click', () => this.handleStandaloneDeAI());
    bind('btn-copy-deai', 'click', () => {
      const out = document.getElementById('deai-output');
      if(out) navigator.clipboard.writeText(out.innerText).then(() => alert('已复制修稿结果'));
    });
    bind('btn-start-pipeline', 'click', () => this.runMasterPipeline());
    bind('btn-export-book', 'click', () => this.exportMarkdown());
  }

  async handleBatchAddProviders() {
    const inp = document.getElementById('inp-batch-keys');
    const rawText = inp ? inp.value.trim() : '';
    if (!rawText) return alert("请先粘贴至少一个 API Key！");

    const parsedList = window.modelGateway.parseBatchKeys(rawText);
    if (parsedList.length === 0) return alert("未能识别出有效的 API Key 格式");

    const btn = document.getElementById('btn-batch-add');
    btn.disabled = true;
    btn.innerText = `正在并发探测 ${parsedList.length} 个密钥中...`;

    let successCount = 0;

    await Promise.all(parsedList.map(async (item) => {
      try {
        const results = await Promise.all([
          window.modelGateway.fetchAccountQuota(item.type, item.key),
          window.modelGateway.fetchRemoteModels(item.type, item.key)
        ]);
        const quotaInfo = results[0];
        const models = results[1];

        const providerData = {
          id: `prov_${item.type}_${Date.now()}_${Math.random().toString(36).substring(2, 5)}`,
          type: item.type,
          apiKey: item.key,
          models: models,
          quota: quotaInfo,
          updatedAt: Date.now()
        };

        await window.novelDB.put('providers', providerData);
        this.providers[providerData.id] = providerData;
        successCount++;
      } catch (err) {
        console.error(`密钥探测失败 [${item.type}]:`, err);
      }
    }));

    this.handleSmartAssign(false);
    this.renderProviders();

    btn.disabled = false;
    btn.innerText = "批量探查并接入";
    if(inp) inp.value = '';

    alert(`批量处理完毕！成功激活 ${successCount} 个服务商。\n已为你分配最优工位！`);
  }

  async handleRefreshAllFreePools() {
    const pKeys = Object.keys(this.providers);
    if (pKeys.length === 0) return alert("当前尚未接入任何 API！");

    const btn = document.getElementById('btn-refresh-all');
    btn.disabled = true;
    btn.innerText = "🔄 探测中...";

    let totalFreeNow = 0;

    for (let i=0; i<pKeys.length; i++) {
      const p = this.providers[pKeys[i]];
      try {
        const results = await Promise.all([
          window.modelGateway.fetchAccountQuota(p.type, p.apiKey, p.baseUrl),
          window.modelGateway.fetchRemoteModels(p.type, p.apiKey, p.baseUrl)
        ]);
        p.quota = results[0];
        p.models = results[1];
        p.updatedAt = Date.now();
        await window.novelDB.put('providers', p);
        totalFreeNow += p.models.filter(m => m.isFree).length;
      } catch (e) {
        console.warn(`刷新供应商 [${p.type}] 异常:`, e);
      }
    }

    this.handleSmartAssign(false);
    this.renderProviders();

    btn.disabled = false;
    btn.innerText = "🔄 刷新免费池";
    alert(`全网同步完成！当前全平台共有 ${totalFreeNow} 个模型免费。`);
  }

  async handleSmartAssign(showAlert) {
    if (Object.keys(this.providers).length === 0) {
      if (showAlert) alert("尚未接入任何 Key，无法分配工位。");
      return;
    }
    this.assignments = window.modelGateway.autoAssignRoles(this.providers);
    await window.novelDB.put('projects', { id: 'assignments', value: this.assignments });
    this.renderProviders();
    if (showAlert) alert("⚡ 智能分工已自适应更新完毕！");
  }

  async handleImportSkill() {
    const url = document.getElementById('inp-skill-url').value.trim();
    if (!url) return alert("请输入 JSON 文件的直链或路径");
    const btn = document.getElementById('btn-import-skill');
    btn.disabled = true;
    try {
      await window.skillManager.importSkill(url);
      this.renderSkills();
      document.getElementById('inp-skill-url').value = '';
      alert('技能装载成功！');
    } catch (e) { alert(e.message); } 
    finally { btn.disabled = false; }
  }

  async handleDeconstruct() {
    const name = document.getElementById('inp-book-name').value.trim();
    const text = document.getElementById('inp-book-text').value.trim();
    if (!name) return alert("必须填写待拆解的小说名字");

    const btn = document.getElementById('btn-deconstruct');
    btn.disabled = true;
    btn.innerText = "正在拆解分析中...";

    try {
      const worker = window.agentDirector.selectWorker('MARKET_ANALYST', this.assignments);
      const res = await window.agentDirector.analyzeBestseller(name, text, worker, this.providers);
      document.getElementById('deconstruct-result').classList.remove('hidden');
      document.getElementById('deconstruct-output').innerText = res;
    } catch (e) { alert("拆书失败: " + e.message); } 
    finally {
      btn.disabled = false;
      btn.innerText = "逆向拆解并生成模板";
    }
  }

  async handleStandaloneDeAI() {
    const raw = document.getElementById('inp-raw-text').value.trim();
    const style = document.getElementById('inp-deai-style').value;
    if (!raw) return alert("请在上方框内粘贴文本");

    const btn = document.getElementById('btn-run-deai');
    btn.disabled = true;
    btn.innerText = "修罗场锻造提纯中...";

    try {
      const worker = window.agentDirector.selectWorker('DE_AI_EDITOR', this.assignments);
      const res = await window.agentDirector.standaloneDeAI(raw, style, worker, this.providers);
      document.getElementById('deai-result').classList.remove('hidden');
      document.getElementById('deai-output').innerText = res;
    } catch (e) { alert("洗稿失败: " + e.message); } 
    finally {
      btn.disabled = false;
      btn.innerText = "执行高维去 AI 味精修";
    }
  }

  renderProviders() {
    const allModels = [];
    Object.keys(this.providers).forEach(k => {
      const p = this.providers[k];
      if(p.models && p.models.length > 0) {
        p.models.forEach(m => {
          allModels.push({
            pId: p.id, mId: m.id, name: `[${p.type}] ${m.id} ${m.isFree ? '(全免费)' : ''}`
          });
        });
      }
    });

    const pKeys = Object.keys(this.providers);
    let listHtml = '';
    for(let i=0; i<pKeys.length; i++) {
      const p = this.providers[pKeys[i]];
      const modelsArray = p.models || [];
      const freeModels = modelsArray.filter(m => m.isFree);
      const quotaText = p.quota && p.quota.text ? p.quota.text : '就绪';
      
      let freeTags = '';
      if (freeModels.length > 0) {
        const sliced = freeModels.slice(0, 8);
        const tags = sliced.map(m => `<span class="text-[9px] bg-zinc-900 text-zinc-300 px-1.5 py-0.5 rounded border border-white/5 font-mono">${m.id}</span>`).join('');
        const more = freeModels.length > 8 ? `<span class="text-[9px] text-zinc-500 self-center">...等${freeModels.length}款</span>` : '';
        freeTags = `<div class="mt-2 flex flex-wrap gap-1 max-h-16 overflow-y-auto">${tags}${more}</div>`;
      }

      listHtml += `
        <div class="bg-zinc-800/50 p-3 rounded-xl border border-white/5 text-xs">
          <div class="flex justify-between items-center mb-1">
            <div class="flex items-center gap-2">
              <b class="text-zinc-200">${p.type.toUpperCase()}</b>
              <span class="text-[10px] bg-emerald-950 text-emerald-400 px-1.5 py-0.2 rounded border border-emerald-800/40">${quotaText}</span>
            </div>
            <button class="text-rose-400 font-bold hover:underline" onclick="window.novelApp.deleteProvider('${p.id}')">移除</button>
          </div>
          <div class="text-[10px] text-zinc-400">
            全部模型: ${modelsArray.length} 款 ｜ <span class="text-emerald-400 font-semibold">可用免费模型: ${freeModels.length} 款</span>
          </div>
          ${freeTags}
        </div>`;
    }
    document.getElementById('providers-list').innerHTML = listHtml;

    const rolesArr = Object.keys(window.agentDirector.roles);
    let rolesHtml = '';
    for(let i=0; i<rolesArr.length; i++) {
      const roleKey = rolesArr[i];
      const roleName = window.agentDirector.roles[roleKey];
      const current = this.assignments[roleKey] || {};
      const reasonTag = current.reason ? `<span class="text-[9px] text-amber-400/80 bg-amber-950/40 px-1 py-0.2 rounded ml-1">${current.reason}</span>` : '';
      
      const opts = allModels.map(m => {
        const isSelected = (current.providerId === m.pId && current.modelId === m.mId) ? 'selected' : '';
        return `<option value="${m.pId}@${m.mId}" ${isSelected}>${m.name}</option>`;
      }).join('');

      rolesHtml += `
        <div class="flex justify-between items-center text-xs border-b border-white/5 py-2">
          <div class="w-1/3 flex flex-col">
            <span class="text-zinc-400 font-semibold">${roleName}</span>
            <div>${reasonTag}</div>
          </div>
          <select class="bg-zinc-800 border border-white/10 rounded-lg p-1.5 w-2/3 text-zinc-200" onchange="window.novelApp.assignRole('${roleKey}', this.value)">
            <option value="">-- 选择接单模型 --</option>
            ${opts}
          </select>
        </div>`;
    }
    document.getElementById('agent-assignments').innerHTML = rolesHtml;
  }

  async assignRole(role, val) {
    if (!val) { delete this.assignments[role]; } 
    else {
      const parts = val.split('@');
      this.assignments[role] = { providerId: parts[0], modelId: parts[1], reason: '用户手动指定' };
    }
    await window.novelDB.put('projects', { id: 'assignments', value: this.assignments });
    this.renderProviders();
  }

  async deleteProvider(id) {
    await window.novelDB.delete('providers', id);
    delete this.providers[id];
    this.handleSmartAssign(false);
    this.renderProviders();
  }

  async renderSkills() {
    const list = await window.novelDB.getAll('skills') || [];
    document.getElementById('skills-list').innerHTML = list.map(s => `
      <div class="bg-zinc-800/60 p-2 rounded-lg border border-sky-900/30 flex justify-between items-start">
        <div>
          <div class="text-[11px] font-bold text-sky-400">${s.name} <span class="text-zinc-500 font-normal ml-1">[${s.category}]</span></div>
          <div class="text-[10px] text-zinc-400 mt-0.5 line-clamp-1">${s.prompt}</div>
        </div>
        <button class="text-rose-400 text-[10px] shrink-0 ml-2" onclick="window.novelApp.deleteSkill('${s.id}')">卸载</button>
      </div>
    `).join('');
  }

  async deleteSkill(id) {
    await window.novelDB.delete('skills', id);
    this.renderSkills();
  }

  logMessage(agent, msg) {
    const box = document.getElementById('pipeline-logs');
    if(!box) return;
    const time = new Date().toLocaleTimeString('zh-CN', { hour12: false });
    const div = document.createElement('div');
    div.className = "flex gap-2 items-start border-b border-white/5 pb-1.5 mt-1";
    div.innerHTML = `<span class="text-zinc-600 shrink-0">[${time}]</span><span class="text-sky-400 font-bold shrink-0">${agent}:</span><span class="text-zinc-300 break-all">${msg}</span>`;
    box.appendChild(div);
    box.scrollTop = box.scrollHeight;
  }

  async runMasterPipeline() {
    const idea = document.getElementById('inp-idea').value.trim();
    const genre = document.getElementById('inp-genre').value;
    const chaptersCount = parseInt(document.getElementById('inp-chapters').value) || 1;
    
    if (!idea) return alert("请先在灵感框输入核心构想！");

    const btn = document.getElementById('btn-start-pipeline');
    btn.disabled = true;
    btn.innerText = "流水线马力全开，推演中...";
    document.getElementById('pipeline-logs').innerHTML = '';
    const statusEl = document.getElementById('pipeline-status');
    if(statusEl) statusEl.innerText = 'RUNNING';

    try {
      const d = window.agentDirector;

      const allSkills = await window.novelDB.getAll('skills') || [];
      const skillsPrompt = allSkills.length > 0 
        ? allSkills.map(s => `[写作技巧铁律 - ${s.name}]: ${s.prompt}`).join('\n')
        : '（未挂载特殊技能设定）';

      this.logMessage('调度中枢', `初始化 ${chaptersCount} 章小说流水线...`);
      const marketPlan = await d.step1_MarketIdeation(idea, genre, d.selectWorker('MARKET_ANALYST', this.assignments), this.providers, this.logMessage.bind(this));
      
      const outlineText = await d.step2_WorldAndOutline(marketPlan, chaptersCount, d.selectWorker('ARCHITECT', this.assignments), this.providers, this.logMessage.bind(this));
      
      await window.novelDB.put('projects', { id: 'current_lore', market: marketPlan, outline: outlineText });
      const loreEl = document.getElementById('lore-container');
      if(loreEl) loreEl.innerText = outlineText;

      let dynamicSummary = "这是开篇首章，世界观即将展开，主角即将遭遇改变命运的节点。";

      for (let i = 1; i <= chaptersCount; i++) {
        const chapTitle = `第 ${i} 章`;
        
        const rawBody = await d.step3_WriteChapter(chapTitle, outlineText, dynamicSummary, skillsPrompt, d.selectWorker('SCRIBE', this.assignments), this.providers, this.logMessage.bind(this));
        
        const polishedBody = await d.step4_DeAI(rawBody, d.selectWorker('DE_AI_EDITOR', this.assignments), this.providers, this.logMessage.bind(this));

        const chapSummary = await d.extractSummary(polishedBody, d.selectWorker('GUARDIAN', this.assignments), this.providers, this.logMessage.bind(this));
        dynamicSummary = `前文重大因果事件回顾：${chapSummary}`; 
        
        await window.novelDB.put('chapters', { id: `chap_${i}`, order: i, title: chapTitle, content: polishedBody, time: Date.now() });
        this.logMessage('本地数据库', `【${chapTitle}】已保存进存储。`);
        
        this.renderChapters(); 
      }

      this.logMessage('系统内核', `🎉 前 ${chaptersCount} 章已全部创作完毕！请切换到【章节】面板查阅。`);
    } catch (e) {
      this.logMessage('异常中断', e.message);
      alert("创作流中断: " + e.message);
    } finally {
      btn.disabled = false;
      btn.innerText = "启动九层流水线创作";
      if(statusEl) statusEl.innerText = 'IDLE';
    }
  }

  async renderChapters() {
    const list = await window.novelDB.getAll('chapters');
    list.sort((a,b) => a.order - b.order);
    const box = document.getElementById('chapters-list');
    
    if (!box) return;
    if (list.length === 0) {
      box.innerHTML = `<div class="text-zinc-600 text-[11px] text-center py-6">原稿库暂无章节</div>`;
      return;
    }

    box.innerHTML = list.map(c => `
      <div class="glass-card p-3.5">
        <div class="flex justify-between items-center mb-2">
          <h4 class="text-sm font-bold text-sky-400">${c.title}</h4>
          <span class="text-[10px] text-zinc-500 bg-zinc-900 px-2 py-0.5 rounded border border-white/5">${(c.content || '').length} 字</span>
        </div>
        <p class="text-xs text-zinc-400 line-clamp-4 mb-3 leading-relaxed whitespace-pre-wrap">${(c.content || '').slice(0, 200)}...</p>
        <button class="bg-zinc-800 hover:bg-zinc-700 text-zinc-200 font-bold w-full py-2 rounded-lg text-xs transition-colors" onclick="window.novelApp.readChapter('${c.id}')">沉浸阅读全文</button>
      </div>
    `).join('');
  }

  async readChapter(id) {
    const c = await window.novelDB.get('chapters', id);
    if(!c) return;
    document.getElementById('reading-title').innerText = c.title;
    document.getElementById('reading-body').innerText = c.content;
    document.getElementById('reading-modal').classList.remove('hidden');
  }

  async exportMarkdown() {
    const list = await window.novelDB.getAll('chapters');
    if(list.length === 0) return alert("数据库为空，请先运行创作。");
    list.sort((a,b) => a.order - b.order);
    
    let text = `# 墨境 AI - 导出成书文稿\n\n`;
    list.forEach(c => {
      text += `## ${c.title}\n\n${c.content}\n\n---\n\n`;
    });
    
    const blob = new Blob([text], {type: 'text/markdown'});
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `墨境全本小说_${Date.now()}.md`;
    a.click();
    URL.revokeObjectURL(url);
  }
}

window.novelApp = new NovelApp();
// 页面脚本加载完毕立即执行，无需等待 DOMContentLoaded
window.novelApp.init();