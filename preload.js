const { contextBridge, ipcRenderer } = require('electron');

// Native storage API used by the web app
contextBridge.exposeInMainWorld('nativeStorage', {
  save: (data) => ipcRenderer.invoke('native-save', data),
  load: () => ipcRenderer.invoke('native-load')
});

// Minimal filesystem helpers (optional)
contextBridge.exposeInMainWorld('nativeFS', {
  selectDirectory: () => ipcRenderer.invoke('select-directory'),
  saveFile: (opts) => ipcRenderer.invoke('save-file', opts)
});

console.log('✅ Preload initialized');
