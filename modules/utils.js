/**
 * Core Utilities Module
 * Contains common utility functions used across the application
 */

const CashBookUtils = {
  
  // Initialize utilities
  init: function() {
    console.log('🔧 Initializing CashBook Utils');
    // Initialize global app state if not exists
    if (!window.appState) {
      window.appState = {
        currentUser: null,
        currentSection: 'dashboard',
        transactions: [],
        employees: [],
        categories: [],
        accounts: [],
        isInitialized: false
      };
    }
    
    // Load from localStorage or migrate from old window.state if exists
    if (!window.appState.isInitialized) {
      window.appState.transactions = this.LS.get('transactions', []);
      window.appState.employees = this.LS.get('employees', []);
      window.appState.categories = this.LS.get('categories', []);
      window.appState.accounts = this.LS.get('accounts', []);
      
      // Migrate from old window.state if exists
      if (window.state) {
        window.appState.transactions = window.state.transactions || window.appState.transactions;
        window.appState.employees = window.state.employees || window.appState.employees;
        window.appState.categories = window.state.categories || window.appState.categories;
        window.appState.accounts = window.state.accounts || window.appState.accounts;
      }
    }
    
    window.appState.isInitialized = true;
    console.log('✅ Global app state initialized');
  },
  
  // localStorage wrapper with error handling
  LS: {
    get: (k, fallback) => {
      try { 
        const v = localStorage.getItem(k); 
        return v ? JSON.parse(v) : fallback; 
      } catch (e) { 
        console.error('LS.get error', k, e); 
        return fallback; 
      }
    },
    set: (k, v) => {
      try { 
        localStorage.setItem(k, JSON.stringify(v)); 
      } catch (e) {
        console.error('LS.set error', k, e);
        alert('Storage error: Unable to save data locally. Please free up storage or try a smaller dataset.');
      }
    },
    remove: (k) => {
      try {
        localStorage.removeItem(k);
      } catch (e) {
        console.error('LS.remove error', k, e);
      }
    }
  },

  // Currency formatting (with thousand separators)
  formatCurrency: function(amount) {
    const num = parseFloat(amount) || 0;
    
    // If it's a whole number, show without decimals
    if (num % 1 === 0) {
      return new Intl.NumberFormat('en-US', { 
        style: 'currency', 
        currency: 'AED',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0 
      }).format(num);
    } else {
      // If it has decimals, show with 2 decimal places
      return new Intl.NumberFormat('en-US', { 
        style: 'currency', 
        currency: 'AED',
        minimumFractionDigits: 2,
        maximumFractionDigits: 2 
      }).format(num);
    }
  },

  // Display amount formatting (with thousand separators, no .00 for whole numbers)
  formatDisplayAmount: function(amount) {
    const num = parseFloat(amount) || 0;
    
    // If it's a whole number, show without decimals but with thousand separators
    if (num % 1 === 0) {
      return new Intl.NumberFormat('en-US', { 
        minimumFractionDigits: 0,
        maximumFractionDigits: 0 
      }).format(num);
    } else {
      // If it has decimals, show with 2 decimal places and thousand separators
      return new Intl.NumberFormat('en-US', { 
        minimumFractionDigits: 2,
        maximumFractionDigits: 2 
      }).format(num);
    }
  },

  // Date formatting for display (DD-MM-YYYY)
  formatDate: function(dateString) {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}-${month}-${year}`;
  },

  // Display date formatting (DD-MM-YYYY)
  formatDisplayDate: function(dateString) {
    if (!dateString) return '';
    const date = new Date(dateString);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}-${month}-${year}`;
  },

  // DateTime formatting (DD-MM-YYYY HH:MM:SS)
  formatDateTime: function(dateTimeString) {
    if (!dateTimeString) return 'N/A';
    const date = new Date(dateTimeString);
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    return `${day}-${month}-${year} ${hours}:${minutes}:${seconds}`;
  },

  // Export-specific amount formatting (with thousand separators, no .00 for whole numbers)
  formatExportAmount: function(amount) {
    const num = parseFloat(amount) || 0;
    
    // Format with thousand separators for exports
    if (num % 1 === 0) {
      return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      }).format(num);
    } else {
      return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(num);
    }
  },

  // Generate unique ID
  generateId: function() {
    return Date.now().toString(36) + Math.random().toString(36).substr(2);
  },

  // Show toast notification
  showToast: function(message, type = 'info') {
    // Simple alert for now - can be enhanced later
    if (type === 'error') {
      alert('Error: ' + message);
    } else {
      console.log('Toast:', message);
    }
  },

  // Filter transactions by date range
  filterByDateRange: function(transactions, startDate, endDate) {
    return transactions.filter(t => {
      const transactionDate = t.date;
      if (startDate && transactionDate < startDate) return false;
      if (endDate && transactionDate > endDate) return false;
      return true;
    });
  },

  // Sort transactions by date
  sortByDate: function(transactions, descending = false) {
    return [...transactions].sort((a, b) => {
      const dateA = new Date(a.date || '1970-01-01');
      const dateB = new Date(b.date || '1970-01-01');
      return descending ? dateB - dateA : dateA - dateB;
    });
  },

  // Calculate sum of transaction amounts
  calculateSum: function(transactions) {
    return transactions.reduce((sum, t) => sum + (parseFloat(t.amount) || 0), 0);
  },

  // Simple number formatting with thousand separators (no currency)
  formatNumber: function(number) {
    const num = parseFloat(number) || 0;
    
    if (num % 1 === 0) {
      return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
      }).format(num);
    } else {
      return new Intl.NumberFormat('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      }).format(num);
    }
  },

  // Sort transactions by amount
  sortByAmount: function(transactions, descending = false) {
    return [...transactions].sort((a, b) => {
      const amountA = parseFloat(a.amount || 0);
      const amountB = parseFloat(b.amount || 0);
      return descending ? amountB - amountA : amountA - amountB;
    });
  },

  // Debounce function
  debounce: function(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  },

  // Validate input
  validateInput: function(value, type = 'text') {
    if (type === 'number') {
      return !isNaN(value) && parseFloat(value) >= 0;
    }
    if (type === 'date') {
      return !isNaN(Date.parse(value));
    }
    return value && value.trim().length > 0;
  },

  // Get date ranges
  getDateRange: function(period) {
    const today = new Date();
    let start, end;

    switch (period) {
      case 'today':
        start = end = today.toISOString().split('T')[0];
        break;
      case 'week':
        const startOfWeek = new Date(today);
        startOfWeek.setDate(today.getDate() - today.getDay());
        start = startOfWeek.toISOString().split('T')[0];
        end = today.toISOString().split('T')[0];
        break;
      case 'month':
        start = new Date(today.getFullYear(), today.getMonth(), 1).toISOString().split('T')[0];
        end = today.toISOString().split('T')[0];
        break;
      case 'quarter':
        const quarterStart = new Date(today.getFullYear(), Math.floor(today.getMonth() / 3) * 3, 1);
        start = quarterStart.toISOString().split('T')[0];
        end = today.toISOString().split('T')[0];
        break;
      case 'year':
        start = new Date(today.getFullYear(), 0, 1).toISOString().split('T')[0];
        end = today.toISOString().split('T')[0];
        break;
      default:
        start = end = today.toISOString().split('T')[0];
    }

    return { start, end };
  },

  // Extract vehicle ID from transaction
  extractVehicleId: function(transaction) {
    // Try to extract vehicle ID from various fields
    const fields = [
      transaction.transactionId,
      transaction.vendor,
      transaction.description,
      transaction.remarks
    ];

    for (const field of fields) {
      if (field) {
        // Look for patterns like ABC-123, ABC123, etc.
        const match = field.match(/[A-Za-z]{1,3}[-\s]?\d{3,5}/);
        if (match) {
          return match[0].toUpperCase();
        }
      }
    }

    return transaction.transactionId || 'Empty';
  },

  // Get time ago string
  getTimeAgo: function(date) {
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / 60000);
    const diffHours = Math.floor(diffMs / 3600000);
    const diffDays = Math.floor(diffMs / 86400000);

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins}m ago`;
    if (diffHours < 24) return `${diffHours}h ago`;
    if (diffDays < 7) return `${diffDays}d ago`;
    return this.formatDate(date.toISOString().split('T')[0]);
  },

  // Notification System
  showNotification: function(message, type = 'success', duration = 2500) {
    const container = document.getElementById('notificationContainer');
    if (!container) return;

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    
    // Set icon based on type
    let icon;
    switch(type) {
      case 'success': icon = 'fa-check-circle'; break;
      case 'error': icon = 'fa-exclamation-circle'; break;
      case 'warning': icon = 'fa-exclamation-triangle'; break;
      case 'info': icon = 'fa-info-circle'; break;
      default: icon = 'fa-check-circle';
    }
    
    notification.innerHTML = `
      <i class="fa-solid ${icon} icon"></i>
      <span class="message">${message}</span>
      <div class="progress-bar"></div>
    `;
    
    // Add to container
    container.appendChild(notification);
    
    // Auto remove after duration
    setTimeout(() => {
      notification.style.animation = 'popOut 0.3s ease-in forwards';
      setTimeout(() => {
        if (notification.parentNode) {
          notification.parentNode.removeChild(notification);
        }
      }, 300);
    }, duration);
    
    return notification;
  },

  // Quick notification methods
  successNotification: function(message) {
    return this.showNotification(message, 'success');
  },
  
  errorNotification: function(message) {
    return this.showNotification(message, 'error');
  },
  
  warningNotification: function(message) {
    return this.showNotification(message, 'warning');
  },
  
  infoNotification: function(message) {
    return this.showNotification(message, 'info');
  }
};

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = CashBookUtils;
}