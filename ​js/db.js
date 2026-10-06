class NovelDB {
  constructor() {
    this.dbName = 'Mojing_OS_DB_V4';
    this.version = 1;
    this.db = null;
  }

  async init() {
    return new Promise((resolve, reject) => {
      const req = indexedDB.open(this.dbName, this.version);
      req.onupgradeneeded = (e) => {
        const db = e.target.result;
        if (!db.objectStoreNames.contains('projects')) db.createObjectStore('projects', { keyPath: 'id' });
        if (!db.objectStoreNames.contains('chapters')) db.createObjectStore('chapters', { keyPath: 'id' });
        if (!db.objectStoreNames.contains('providers')) db.createObjectStore('providers', { keyPath: 'id' });
        if (!db.objectStoreNames.contains('skills')) db.createObjectStore('skills', { keyPath: 'id' });
      };
      req.onsuccess = (e) => { 
        this.db = e.target.result; 
        resolve(this); 
      };
      req.onerror = (e) => reject(e.target.error);
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