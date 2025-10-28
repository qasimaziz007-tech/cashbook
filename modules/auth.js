/**
 * Authentication Module
 * Handles user login/logout functionality
 */

const AuthModule = {
  
  // Initialize authentication
  init: function() {
    console.log('🔐 Initializing Authentication Module');
    this.checkExistingSession();
    this.bindEvents();
  },

  // Bind authentication events
  bindEvents: function() {
    // Login form events
    const loginBtn = document.querySelector('#loginScreen button');
    if (loginBtn) {
      loginBtn.addEventListener('click', (e) => {
        e.preventDefault();
        this.login();
      });
    }

    // Enter key on password field
    const loginPass = document.getElementById('loginPass');
    if (loginPass) {
      loginPass.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
          this.login();
        }
      });
    }
  },

  // Check for existing session
  checkExistingSession: function() {
    try {
      const currentUser = sessionStorage.getItem('currentUser');
      if (currentUser) {
        const user = JSON.parse(currentUser);
        if (user && this.validateUser(user.username, user.password)) {
          this.loginSuccess(user);
        } else {
          this.logout();
        }
      }
    } catch (e) {
      console.error('Session check error:', e);
      this.logout();
    }
  },

  // Perform login
  login: function() {
    const username = document.getElementById('loginUser').value.trim();
    const password = document.getElementById('loginPass').value;

    if (!username || !password) {
      alert('Please enter username and password');
      return;
    }

    const user = this.validateUser(username, password);
    if (user) {
      this.loginSuccess(user);
    } else {
      alert('Invalid username or password');
      document.getElementById('loginPass').value = '';
    }
  },

  // Validate user credentials
  validateUser: function(username, password) {
    // Get users from localStorage or use default admin
    const users = CashBookUtils.LS.get('users', [
      { username: 'admin', password: 'admin', role: 'admin' },
      { username: 'user', password: 'user', role: 'user' }
    ]);

    return users.find(u => u.username === username && u.password === password);
  },

  // Handle successful login
  loginSuccess: function(user) {
    // Set global state
    window.appState.currentUser = user;
    sessionStorage.setItem('currentUser', JSON.stringify(user));
    
    // Also set in localStorage for compatibility
    CashBookUtils.LS.set('currentUser', user);

    // Update UI
    const currentUserEl = document.getElementById('currentUser');
    if (currentUserEl) {
      currentUserEl.textContent = user.username;
    }
    
    const appEl = document.getElementById('app');
    const loginScreenEl = document.getElementById('loginScreen');
    const menuEl = document.getElementById('menu');
    
    if (appEl) appEl.classList.remove('hidden');
    if (loginScreenEl) loginScreenEl.classList.add('hidden');
    if (menuEl) menuEl.classList.remove('hidden');

    // Initialize the application
    this.initializeApp();
  },

  // Initialize app after login
  initializeApp: function() {
    // Load data from localStorage
    try {
      const transactions = CashBookUtils.LS.get('transactions', []);
      const employees = CashBookUtils.LS.get('employees', []);
      
      window.appState.transactions = Array.isArray(transactions) ? transactions : [];
      window.appState.employees = Array.isArray(employees) ? employees : [];
      
      console.log(`📊 Loaded ${window.appState.transactions.length} transactions`);
      console.log(`👥 Loaded ${window.appState.employees.length} employees`);
    } catch (error) {
      console.error('Failed to load app data:', error);
      window.appState.transactions = [];
      window.appState.employees = [];
    }

    // Show default section (transactions)
    if (typeof showSection === 'function') {
      showSection('transactions');
    }

    // Load initial data for UI
    setTimeout(() => {
      if (typeof loadTransactions === 'function') loadTransactions();
      if (typeof loadDashboard === 'function') loadDashboard();
      if (typeof loadCategories === 'function') loadCategories();
      if (typeof loadAccounts === 'function') loadAccounts();
    }, 100);

    console.log('✅ User logged in successfully:', window.appState.currentUser.username);
  },

  // Logout user
  logout: function() {
    // Clear global state
    window.appState.currentUser = null;
    sessionStorage.removeItem('currentUser');
    CashBookUtils.LS.remove('currentUser');

    // Update UI
    const appEl = document.getElementById('app');
    const loginScreenEl = document.getElementById('loginScreen');
    const menuEl = document.getElementById('menu');
    const loginUserEl = document.getElementById('loginUser');
    const loginPassEl = document.getElementById('loginPass');
    
    if (appEl) appEl.classList.add('hidden');
    if (loginScreenEl) loginScreenEl.classList.remove('hidden');
    if (menuEl) menuEl.classList.add('hidden');
    
    // Clear form fields
    if (loginUserEl) loginUserEl.value = '';
    if (loginPassEl) loginPassEl.value = '';

    console.log('👋 User logged out');
  },

  // Get current user
  getCurrentUser: function() {
    return window.appState.currentUser;
  },

  // Check if user is admin
  isAdmin: function() {
    const user = this.getCurrentUser();
    return user && user.role === 'admin';
  },

  // Check if user is authenticated
  isAuthenticated: function() {
    return !!this.getCurrentUser();
  }
};

// Global functions for backwards compatibility
function login() {
  AuthModule.login();
}

function logout() {
  AuthModule.logout();
}

function handleLoginKeyPress(event) {
  if (event.key === 'Enter') {
    AuthModule.login();
  }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = AuthModule;
}