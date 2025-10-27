const { app, BrowserWindow, shell, ipcMain, dialog } = require('electron');
const path = require('path');
const fs = require('fs').promises;

let mainWindow;

function createWindow() {
  const iconPath = path.join(__dirname, 'assets', 'icon.png');
  const winOpts = {
    width: 1280,
    height: 800,
    minWidth: 1024,
    minHeight: 700,
    title: 'Esthetics Auto Cashbook',
    backgroundColor: '#f5f7fa',
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true
    }
  };
  try {
    const fsSync = require('fs');
    if (fsSync.existsSync(iconPath)) {
      winOpts.icon = iconPath;
    }
  } catch {}

  mainWindow = new BrowserWindow(winOpts);

  mainWindow.loadFile('index.html');

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    if (url.startsWith('http')) {
      shell.openExternal(url);
      return { action: 'deny' };
    }
    return { action: 'allow' };
  });

  mainWindow.on('closed', () => {
    mainWindow = null;
  });
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

// IPC: Select directory
ipcMain.handle('select-directory', async () => {
  const result = await dialog.showOpenDialog(mainWindow, {
    properties: ['openDirectory', 'createDirectory']
  });
  if (!result.canceled && result.filePaths.length > 0) {
    return { success: true, path: result.filePaths[0] };
  }
  return { success: false };
});

// IPC: Save file
ipcMain.handle('save-file', async (event, { data, fileName, directory }) => {
  try {
    let filePath;
    if (directory) {
      filePath = path.join(directory, fileName);
    } else {
      const result = await dialog.showSaveDialog(mainWindow, {
        defaultPath: fileName
      });
      if (result.canceled) return { success: false, message: 'Save cancelled' };
      filePath = result.filePath;
    }

    let buffer;
    if (typeof data === 'string' && data.startsWith('data:')) {
      const base64Data = data.split(',')[1];
      buffer = Buffer.from(base64Data, 'base64');
    } else if (typeof data === 'string') {
      buffer = Buffer.from(data, 'utf8');
    } else {
      buffer = Buffer.from(data);
    }

    await fs.writeFile(filePath, buffer);
    return { success: true, path: filePath };
  } catch (error) {
    console.error('Save file error:', error);
    return { success: false, error: error.message };
  }
});

// IPC: Native storage save/load used by web code
ipcMain.handle('native-save', async (event, data) => {
  try {
    const userDataPath = app.getPath('userData');
    const dataPath = path.join(userDataPath, 'app-data.json');
    await fs.writeFile(dataPath, JSON.stringify(data, null, 2), 'utf8');
    return { success: true, path: dataPath };
  } catch (error) {
    return { success: false, error: error.message };
  }
});

ipcMain.handle('native-load', async () => {
  try {
    const userDataPath = app.getPath('userData');
    const dataPath = path.join(userDataPath, 'app-data.json');
    const data = await fs.readFile(dataPath, 'utf8');
    return { success: true, data: JSON.parse(data) };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
console.log('📁 User data path:', app.getPath('userData'));
