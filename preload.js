const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process to use
// the ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  selectBackupFolder: () => ipcRenderer.invoke('select-backup-folder'),
  saveBackupFile: (data, defaultName) => ipcRenderer.invoke('save-backup-file', data, defaultName),
  onMenuAction: (callback) => ipcRenderer.on('menu-action', callback),
  removeAllListeners: (channel) => ipcRenderer.removeAllListeners(channel),
  
  // Platform info
  platform: process.platform,
  
  // App info
  getAppVersion: () => ipcRenderer.invoke('get-app-version')
});