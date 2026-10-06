class ModelGateway {
  constructor() {
    this.knownProviders = {
      openrouter: {
        name: 'OpenRouter',
        baseUrl: 'https://openrouter.ai/api/v1',
        authKeyUrl: 'https://openrouter.ai/api/v1/auth/key',
        isFreeModel: (m) => {
          if (m.id && m.id.endsWith(':free')) return true;
          if (m.pricing) {
            const promptCost = parseFloat(m.pricing.prompt || '0');
            const compCost = parseFloat(m.pricing.completion || '0');
            return promptCost === 0 && compCost === 0;
          }
          return false;
        }
      },
      siliconflow: {
        name: '硅基流动',
        baseUrl: 'https://api.siliconflow.cn/v1',
        userInfoUrl: 'https://api.siliconflow.cn/v1/user/info',
        isFreeModel: (m) => {
          const id = (m.id || '').toLowerCase();
          return id.includes('free') || id.includes('qwen/qwen2.5-7b') || id.includes('thudm/glm-4-9b') || id.includes('telechat2');
        }
      },
      zhipu: {
        name: '智谱 AI',
        baseUrl: 'https://open.bigmodel.cn/api/paas/v4',
        isFreeModel: (m) => (m.id || '').toLowerCase().includes('glm-4-flash')
      },
      groq: {
        name: 'Groq Cloud',
        baseUrl: 'https://api.groq.com/openai/v1',
        isFreeModel: () => true
      },
      deepseek: {
        name: 'DeepSeek 官方',
        baseUrl: 'https://api.deepseek.com',
        balanceUrl: 'https://api.deepseek.com/user/balance',
        isFreeModel: () => false
      },
      custom: {
        name: '自定义接口',
        baseUrl: '',
        isFreeModel: (m) => (m.id || '').toLowerCase().includes('free')
      }
    };
  }

  async fetchAccountQuota(providerKey, apiKey, customUrl = '') {
    const config = this.knownProviders[providerKey] || this.knownProviders.custom;

    if (providerKey === 'siliconflow') {
      try {
        const res = await fetch(config.userInfoUrl, { headers: { 'Authorization': `Bearer ${apiKey}` } });
        if (res.ok) {
          const json = await res.json();
          if (json.data && json.data.balance !== undefined) {
            return { text: `余额 ¥${parseFloat(json.data.balance).toFixed(2)}`, isAvailable: parseFloat(json.data.balance) > 0 };
          }
        }
      } catch (e) { console.warn('硅基流动查额度受阻:', e); }
      return { text: '含海量免费池', isAvailable: true };
    }

    if (providerKey === 'openrouter') {
      try {
        const res = await fetch(config.authKeyUrl, { headers: { 'Authorization': `Bearer ${apiKey}` } });
        if (res.ok) {
          const json = await res.json();
          const d = json.data;
          const limitStr = d.limit ? `$${d.limit}` : '无限额';
          return { text: `已用 $${(d.usage || 0).toFixed(2)} / 限额 ${limitStr}`, isAvailable: true };
        }
      } catch (e) { console.warn('OpenRouter 查额度受阻:', e); }
      return { text: '全网动态免费池就绪', isAvailable: true };
    }

    if (providerKey === 'deepseek') {
      try {
        const res = await fetch(config.balanceUrl, { headers: { 'Authorization': `Bearer ${apiKey}` } });
        if (res.ok) {
          const json = await res.json();
          const info = json.balance_infos?.[0];
          if (info) return { text: `余额 ¥${parseFloat(info.total_balance).toFixed(2)}`, isAvailable: parseFloat(info.total_balance) > 0 };
        }
      } catch (e) { console.warn('DeepSeek 查额度受阻:', e); }
    }

    if (providerKey === 'zhipu') return { text: 'GLM-4-Flash 永久免费', isAvailable: true };
    if (providerKey === 'groq') return { text: '高速开发者免费层', isAvailable: true };

    return { text: 'API 就绪', isAvailable: true };
  }

  async fetchRemoteModels(providerKey, apiKey, customUrl = '') {
    const config = this.knownProviders[providerKey] || { baseUrl: customUrl };
    let url = (customUrl || config.baseUrl).replace(/\/+$/, '') + '/models';

    const res = await fetch(url, {
      headers: { 'Authorization': `Bearer ${apiKey}`, 'Content-Type': 'application/json' }
    });

    if (!res.ok) throw new Error(`HTTP ${res.status}: 无法获取模型列表`);

    const data = await res.json();
    const rawList = Array.isArray(data) ? data : (data.data || []);

    return rawList.map(m => {
      const mId = m.id || m.name;
      const isFree = config.isFreeModel ? config.isFreeModel(m) : false;
      return {
        id: mId,
        name: m.name || mId,
        isFree: Boolean(isFree),
        provider: providerKey,
        traits: this.profileModelCapabilities(mId, isFree)
      };
    });
  }

  profileModelCapabilities(modelId, isFree) {
    const id = modelId.toLowerCase();
    return {
      isReasoning: id.includes('r1') || id.includes('reasoner') || id.includes('o1') || id.includes('o3'),
      isFlagship: id.includes('70b') || id.includes('72b') || id.includes('v3') || id.includes('4o') || id.includes('claude'),
      isFast: id.includes('flash') || id.includes('8b') || id.includes('7b') || id.includes('mini') || id.includes('instant'),
      isCreative: id.includes('qwen') || id.includes('deepseek') || id.includes('glm'),
      isFree: Boolean(isFree)
    };
  }

  parseBatchKeys(text) {
    const lines = text.split('\n').map(l => l.trim()).filter(Boolean);
    const results = [];

    for (const line of lines) {
      if (line.includes(':') && !line.startsWith('http')) {
        const parts = line.split(':');
        const pType = parts[0].trim().toLowerCase();
        const pKey = parts.slice(1).join(':').trim();
        if (this.knownProviders[pType] && pKey) {
          results.push({ type: pType, key: pKey });
          continue;
        }
      }
      if (line.startsWith('sk-or-')) results.push({ type: 'openrouter', key: line });
      else if (line.startsWith('gsk_')) results.push({ type: 'groq', key: line });
      else if (line.length === 32 || line.startsWith('sk-')) results.push({ type: 'siliconflow', key: line });
      else if (line.includes('.') && line.length > 30) results.push({ type: 'zhipu', key: line });
      else results.push({ type: 'custom', key: line });
    }
    return results;
  }

  autoAssignRoles(providers) {
    const allModels = [];
    Object.values(providers).forEach(p => {
      if(!Array.isArray(p.models)) return;
      p.models.forEach(m => {
        allModels.push({
          providerId: p.id,
          providerType: p.type,
          modelId: m.id,
          isFree: m.isFree,
          traits: m.traits || this.profileModelCapabilities(m.id, m.isFree)
        });
      });
    });

    if (allModels.length === 0) return {};

    const assignments = {};
    const getBest = (scorer) => [...allModels].sort((a, b) => scorer(b) - scorer(a))[0];

    const architect = getBest(m => (m.traits.isReasoning ? 100 : 0) + (m.traits.isFlagship ? 50 : 0) + (m.traits.isCreative ? 20 : 0));
    assignments['ARCHITECT'] = { providerId: architect?.providerId, modelId: architect?.modelId, reason: architect?.traits.isReasoning ? '满血深度推理' : '大参数旗舰' };

    const market = getBest(m => (m.traits.isFlagship ? 80 : 0) + (m.traits.isReasoning ? 50 : 0));
    assignments['MARKET_ANALYST'] = { providerId: market?.providerId, modelId: market?.modelId, reason: '爆款逻辑拆解' };

    const scribe = getBest(m => (m.isFree ? 200 : -100) + (m.traits.isCreative ? 50 : 0) + (m.traits.isFlagship ? 30 : 0));
    assignments['SCRIBE'] = { providerId: scribe?.providerId, modelId: scribe?.modelId, reason: scribe?.isFree ? '动态 0 成本主力' : '高画质网文写手' };

    const editor = getBest(m => (m.traits.isCreative ? 80 : 0) + (m.isFree ? 50 : 0));
    assignments['DE_AI_EDITOR'] = { providerId: editor?.providerId, modelId: editor?.modelId, reason: '中文去AI味特化' };

    const guardian = getBest(m => (m.isFree ? 200 : -100) + (m.traits.isFast ? 80 : 0));
    assignments['GUARDIAN'] = { providerId: guardian?.providerId, modelId: guardian?.modelId, reason: '高速免费轻量守卫' };

    return assignments;
  }

  async chatCompletion({ providerConfig, modelId, messages, maxTokens = 3000, temperature = 0.7, retries = 3 }) {
    let url = (providerConfig.baseUrl || this.knownProviders[providerConfig.type]?.baseUrl || '').replace(/\/+$/, '') + '/chat/completions';
    const payload = { model: modelId, messages, temperature, max_tokens: maxTokens, stream: false };

    for (let attempt = 1; attempt <= retries; attempt++) {
      try {
        const res = await fetch(url, {
          method: 'POST',
          headers: { 'Authorization': `Bearer ${providerConfig.apiKey}`, 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        if (!res.ok) {
          if (res.status === 429) throw new Error('触发免费模型并发频次限制 (429)');
          const errText = await res.text();
          throw new Error(`API 异常 [HTTP ${res.status}]: ${errText.slice(0, 80)}`);
        }
        const data = await res.json();
        return data.choices[0].message.content;
      } catch (err) {
        if (attempt === retries) throw err;
        console.warn(`第 ${attempt} 次请求重试中: ${err.message}...`);
        await new Promise(r => setTimeout(r, attempt * 2000));
      }
    }
  }
}

window.modelGateway = new ModelGateway();