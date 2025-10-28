/**
 * Transactions Module
 * Handles all transaction management functionality
 */

const TransactionsModule = {
  
  // Initialize transactions module
  init: function() {
    console.log('💳 Initializing Transactions Module');
    this.bindEvents();
    this.setupTypeToggle();
    this.setupForm();
    this.loadTransactions();
    this.updateCategoryDropdown();
    this.updateAccountDropdown();
  },

  // Setup transaction form
  setupForm: function() {
    // Set default date to today
    const dateField = document.getElementById('date');
    if (dateField && !dateField.value) {
      dateField.value = new Date().toISOString().split('T')[0];
    }
  },

  // Bind transaction events
  bindEvents: function() {
    const transactionForm = document.getElementById('transactionForm');
    if (transactionForm) {
      transactionForm.addEventListener('submit', (e) => {
        e.preventDefault();
        this.addTransaction();
      });
    }

    // Type toggle buttons
    const incomeBtn = document.getElementById('btnTypeIncome');
    const expenseBtn = document.getElementById('btnTypeExpense');
    
    if (incomeBtn) {
      incomeBtn.addEventListener('click', (e) => {
        e.preventDefault();
        this.setTransactionType('income');
      });
    }
    
    if (expenseBtn) {
      expenseBtn.addEventListener('click', (e) => {
        e.preventDefault();
        this.setTransactionType('expense');
      });
    }
  },

  // Setup type toggle functionality
  setupTypeToggle: function() {
    // Set default to expense
    this.setTransactionType('expense');
  },

  // Set transaction type
  setTransactionType: function(type) {
    const sel = document.getElementById('transactionType');
    const incomeBtn = document.getElementById('btnTypeIncome');
    const expenseBtn = document.getElementById('btnTypeExpense');
    
    if (sel) sel.value = type;
    
    if (incomeBtn && expenseBtn) {
      incomeBtn.classList.toggle('active', type === 'income');
      expenseBtn.classList.toggle('active', type === 'expense');
    }
  },

  // Load all transactions
  loadTransactions: function() {
    const tbody = document.querySelector('#transactionsTable tbody');
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    if (!window.appState.transactions || window.appState.transactions.length === 0) {
      const row = document.createElement('tr');
      row.innerHTML = '<td colspan="9" style="text-align:center;color:#6b7280;padding:20px">No transactions found</td>';
      tbody.appendChild(row);
      return;
    }
    
    // Sort transactions by date (newest first)
    const sortedTransactions = CashBookUtils.sortByDate(window.appState.transactions, true);
    
    sortedTransactions.forEach((t, index) => {
      const row = document.createElement('tr');
      
      const canEdit = this.canEditTransaction(t);
      const editButton = canEdit ? 
        `<button class="action-btn" onclick="TransactionsModule.editTransaction(${index})" title="Edit"><i class="fa-solid fa-edit"></i></button>` : '';
      const deleteButton = canEdit ? 
        `<button class="action-btn" onclick="TransactionsModule.deleteTransaction(${index})" title="Delete"><i class="fa-solid fa-trash" style="color:#ef4444"></i></button>` : '';
      
      row.innerHTML = `
        <td>${CashBookUtils.formatDisplayDate(t.date)}</td>
        <td>${t.category || ''}</td>
        <td>${t.transactionId || '-'}</td>
        <td>${t.vendor || '-'}</td>
        <td>${t.account || ''}</td>
        <td class="${t.type === 'income' ? 'income' : 'expense'}">${CashBookUtils.formatCurrency(t.amount)}</td>
        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${t.description || '-'}</td>
        <td class="${t.type === 'income' ? 'income' : 'expense'}" style="text-transform:capitalize">${t.type || ''}</td>
        <td>${editButton}${deleteButton}</td>
      `;
      
      tbody.appendChild(row);
    });
  },

  // Add new transaction
  addTransaction: function() {
    // Get form values directly from elements
    const date = document.getElementById('date').value.trim();
    const category = document.getElementById('category').value.trim();
    const transactionId = document.getElementById('transactionId').value.trim();
    const vendor = document.getElementById('vendor').value.trim();
    const account = document.getElementById('account').value.trim();
    const amount = document.getElementById('amount').value.trim();
    const description = document.getElementById('description').value.trim();
    const transactionType = document.getElementById('transactionType').value || 'expense';
    
    // Validate required fields
    // Enhanced validation with focus management
    if (!date) {
      alert('Please enter a valid date');
      document.getElementById('date').focus();
      return;
    }
    
    if (!category || category === 'Select Category') {
      alert('Please select a category');
      document.getElementById('category').focus();
      return;
    }
    
    if (!account || account === 'Select Account') {
      alert('Please select an account');
      document.getElementById('account').focus();
      return;
    }
    
    if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
      alert('Please enter a valid amount');
      document.getElementById('amount').focus();
      return;
    }
    
    const transaction = {
      id: CashBookUtils.generateId(),
      date: date,
      category: category,
      transactionId: transactionId || '',
      vendor: vendor || '',
      account: account,
      amount: parseFloat(amount),
      description: description || '',
      type: transactionType,
      createdAt: new Date().toISOString(),
      createdBy: window.appState.currentUser?.username || 'anonymous',
      editedAt: null,
      editedBy: null
    };
    
    // Add to state
    window.appState.transactions.unshift(transaction);
    CashBookUtils.LS.set('transactions', window.appState.transactions);
    
    // Sync to Firebase if available
    if (typeof FirebaseModule !== 'undefined' && FirebaseModule.addTransaction) {
      FirebaseModule.addTransaction(transaction).catch(error => {
        console.error('Failed to sync transaction to Firebase:', error);
      });
    }
    
    // Reset form and reload
    this.resetForm();
    this.loadTransactions();
    
    // Update dashboard if visible
    try {
      if (typeof loadDashboardTransactions === 'function') {
        loadDashboardTransactions();
      }
    } catch (e) {
      console.log('Dashboard update skipped');
    }
    
    // Show success notification
    CashBookUtils.successNotification('✅ Transaction saved successfully!');
  },

  // Edit transaction
  editTransaction: function(index) {
    const t = window.appState.transactions[index];
    if (!this.canEditTransaction(t)) {
      alert('You can only edit your own transactions within 10 minutes of creation, or be an admin.');
      return;
    }
    
    // Populate form with transaction data
    document.getElementById('date').value = t.date;
    document.getElementById('category').value = t.category;
    document.getElementById('transactionId').value = t.transactionId || '';
    document.getElementById('vendor').value = t.vendor || '';
    document.getElementById('account').value = t.account;
    document.getElementById('amount').value = t.amount;
    document.getElementById('description').value = t.description || '';
    this.setTransactionType(t.type);
    
    // Remove the old transaction
    window.appState.transactions.splice(index, 1);
    CashBookUtils.LS.set('transactions', window.appState.transactions);
    
    this.loadTransactions();
    
    // Update dashboard
    try {
      if (typeof loadDashboardTransactions === 'function') {
        loadDashboardTransactions();
      }
    } catch (e) {
      console.log('Dashboard update skipped');
    }
  },

  // Delete transaction
  deleteTransaction: function(index) {
    const t = window.appState.transactions[index];
    if (!this.canEditTransaction(t)) {
      alert('You can only delete your own transactions within 10 minutes of creation, or be an admin.');
      return;
    }
    
    if (confirm('Are you sure you want to delete this transaction?')) {
      window.appState.transactions.splice(index, 1);
      CashBookUtils.LS.set('transactions', window.appState.transactions);
      
      this.loadTransactions();
      
      // Update dashboard
      try {
        if (typeof loadDashboardTransactions === 'function') {
          loadDashboardTransactions();
        }
        if (typeof loadDashboard === 'function') {
          loadDashboard();
        }
      } catch (e) {
        console.log('Dashboard update skipped');
      }
      
      CashBookUtils.showToast('Transaction deleted');
    }
  },

  // Check if user can edit transaction
  canEditTransaction: function(transaction) {
    const currentUser = window.appState.currentUser;
    if (!currentUser) return false;
    
    // Admin can edit anything
    if (currentUser.role === 'admin') return true;
    
    // User can edit their own transactions within 10 minutes
    if (transaction.createdBy === currentUser.username) {
      const createdAt = new Date(transaction.createdAt);
      const now = new Date();
      const diffMinutes = (now - createdAt) / (1000 * 60);
      return diffMinutes <= 10;
    }
    
    return false;
  },

  // Reset transaction form
  resetForm: function() {
    const form = document.getElementById('transactionForm');
    if (form) {
      // Save current values that should be preserved
      const currentDate = document.getElementById('date').value;
      const currentCategory = document.getElementById('category').value;
      const currentAccount = document.getElementById('account').value;
      const currentType = document.getElementById('transactionType').value;
      
      // Reset form
      form.reset();
      
      // Restore preserved values
      if (currentDate) {
        document.getElementById('date').value = currentDate;
      } else {
        // Set default date to today if no date was selected
        document.getElementById('date').value = new Date().toISOString().split('T')[0];
      }
      
      if (currentCategory) {
        document.getElementById('category').value = currentCategory;
      }
      
      if (currentAccount) {
        document.getElementById('account').value = currentAccount;
      }
      
      // Restore transaction type
      this.setTransactionType(currentType || 'expense');
    }
  },

  // Update category dropdown
  updateCategoryDropdown: function() {
    const categorySelect = document.getElementById('category');
    if (!categorySelect) return;
    
    // Get categories from localStorage - use whatever is saved, don't add defaults
    const categories = CashBookUtils.LS.get('categories', []);
    
    categorySelect.innerHTML = '<option value="">Select Category</option>';
    
    categories.forEach(category => {
      const option = document.createElement('option');
      option.value = category;
      option.textContent = category;
      categorySelect.appendChild(option);
    });
    
    // Update global state
    window.appState.categories = categories;
  },

  // Update account dropdown
  updateAccountDropdown: function() {
    const accountSelect = document.getElementById('account');
    if (!accountSelect) return;
    
    // Get accounts from localStorage - use whatever is saved, don't add defaults
    const accounts = CashBookUtils.LS.get('accounts', []);
    
    accountSelect.innerHTML = '<option value="">Select Account</option>';
    
    accounts.forEach(account => {
      const option = document.createElement('option');
      option.value = account;
      option.textContent = account;
      accountSelect.appendChild(option);
    });
    
    // Update global state
    window.appState.accounts = accounts;
  }
};

// Global functions for backwards compatibility
function addTransaction() {
  TransactionsModule.addTransaction();
}

function loadTransactions() {
  TransactionsModule.loadTransactions();
}

function editTransaction(index) {
  TransactionsModule.editTransaction(index);
}

function deleteTransaction(index) {
  TransactionsModule.deleteTransaction(index);
}

function setTxnType(type) {
  TransactionsModule.setTransactionType(type);
}

function updateCategoryDropdown() {
  TransactionsModule.updateCategoryDropdown();
}

function updateAccountDropdown() {
  TransactionsModule.updateAccountDropdown();
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = TransactionsModule;
}