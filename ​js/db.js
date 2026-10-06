class NovelDB {
  constructor() {
    this.dbName = 'Mojing_OS_DB_V4';
    this.version = 1;
    this.db = null;
    this.isFallback = false;
    this.memStore = { projects: {}, chapters: {}, providers: {}, skills: {} };
  }

  async init() {
    return new Promise((resolve) => {
      if (!window.indexedDB) {
        this.enableFallback("当前浏览器不支持数据库功能");
        return resolve(this);
      }

      let isResolved = false;
      try {
        const req = indexedDB.open(this.dbName, this.version);
        
        // 极短超时：3秒内数据库没有响应，立刻触发内存降级，绝对不能阻塞用户使用！
        const timeoutId = setTimeout(() => {
          if (!isResolved) {
            this.enableFallback("底层数据库连接超时挂起");
            resolve(this);
          }
        }, 3000);

        req.onupgradeneeded = (e) => {
          const db = e.target.result;
          if (!db.objectStoreNames.contains('projects')) db.createObjectStore('projects', { keyPath: 'id' });
          if (!db.objectStoreNames.contains('chapters')) db.createObjectStore('chapters', { keyPath: 'id' });
          if (!db.objectStoreNames.contains('providers')) db.createObjectStore('providers', { keyPath: 'id' });
          if (!db.objectStoreNames.contains('skills')) db.createObjectStore('skills', { keyPath: 'id' });
        };

        req.onsuccess = (e) => { 
          isResolved = true;
          clearTimeout(timeoutId);
          this.db = e.target.result; 
          resolve(this); 
        };

        req.onerror = (e) => {
          isResolved = true;
          clearTimeout(timeoutId);
          this.enableFallback("数据库访问被浏览器拒绝");
          resolve(this);
        };
      } catch (e) {
        this.enableFallback("数据库组件引发崩溃: " + e.message);
        resolve(this);
      }
    });
  }

  // 触发内存降级，通过事件派发通知给前端 UI
  enableFallback(reason) {
    this.isFallback = true;
    const evt = new CustomEvent('db-fallback', { detail: reason });
    window.dispatchEvent(evt);
  }

  async put(store, data) {
    if (this.isFallback) {
      this.memStore[store][data.id] = data;
      return;
    }
    return new Promise((res, rej) => {
      try {
        const req = this.db.transaction([store], 'readwrite').objectStore(store).put(data);
        req.onsuccess = () => res(req.result); 
        req.onerror = () => rej(req.error);
      } catch(e) { rej(e); }
    });
  }

  async getAll(store) {
    if (this.isFallback) {
      const vals = [];
      for (const key in this.memStore[store]) {
        if (this.memStore[store].hasOwnProperty(key)) vals.push(this.memStore[store][key]);
      }
      return vals;
    }
    return new Promise((res, rej) => {
      try {
        const req = this.db.transaction([store], 'readonly').objectStore(store).getAll();
        req.onsuccess = () => res(req.result); 
        req.onerror = () => rej(req.error);
      } catch(e) { rej(e); }
    });
  }

  async get(store, key) {
    if (this.isFallback) return this.memStore[store][key] || null;
    return new Promise((res, rej) => {
      try {
        const req = this.db.transaction([store], 'readonly').objectStore(store).get(key);
        req.onsuccess = () => res(req.result); 
        req.onerror = () => rej(req.error);
      } catch(e) { rej(e); }
    });
  }

  async delete(store, key) {
    if (this.isFallback) {
      delete this.memStore[store][key];
      return;
    }
    return new Promise((res, rej) => {
      try {
        const req = this.db.transaction([store], 'readwrite').objectStore(store).delete(key);
        req.onsuccess = () => res(); 
        req.onerror = () => rej(req.error);
      } catch(e) { rej(e); }
    });
  }
}

window.novelDB = new NovelDB();