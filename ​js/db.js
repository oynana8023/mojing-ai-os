class NovelDB {
  constructor() {
    this.dbName = 'Mojing_OS_DB_V4';
    this.version = 1;
    this.db = null;
  }

  async init() {
    return new Promise((resolve, reject) => {
      if (!window.indexedDB) {
         return reject(new Error("当前浏览器不支持 IndexedDB 本地数据库。"));
      }

      let isResolved = false;
      
      try {
        const req = indexedDB.open(this.dbName, this.version);
        
        // 5秒超时强制抛出错误，防止浏览器静默挂起导致白屏
        const timeoutId = setTimeout(() => {
          if (!isResolved) reject(new Error("数据库连接超时 (可能被浏览器安全策略静默拦截)。"));
        }, 5000);

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
          reject(new Error("数据库访问被拒绝: " + (e.target.error?.message || "未知错误，可能是隐私模式限制")));
        };

        req.onblocked = () => {
          isResolved = true;
          clearTimeout(timeoutId);
          reject(new Error("数据库升级被阻塞，请关闭其他占用该网页的标签页。"));
        };
      } catch (e) {
        reject(new Error("无法打开数据库，严重安全限制: " + e.message));
      }
    });
  }

  async put(store, data) {
    return new Promise((res, rej) => {
      const req = this.db.transaction([store], 'readwrite').objectStore(store).put(data);
      req.onsuccess = () => res(req.result); 
      req.onerror = () => rej(req.error);
    });
  }

  async getAll(store) {
    return new Promise((res, rej) => {
      const req = this.db.transaction([store], 'readonly').objectStore(store).getAll();
      req.onsuccess = () => res(req.result); 
      req.onerror = () => rej(req.error);
    });
  }

  async get(store, key) {
    return new Promise((res, rej) => {
      const req = this.db.transaction([store], 'readonly').objectStore(store).get(key);
      req.onsuccess = () => res(req.result); 
      req.onerror = () => rej(req.error);
    });
  }

  async delete(store, key) {
    return new Promise((res, rej) => {
      const req = this.db.transaction([store], 'readwrite').objectStore(store).delete(key);
      req.onsuccess = () => res(); 
      req.onerror = () => rej(req.error);
    });
  }
}

window.novelDB = new NovelDB();