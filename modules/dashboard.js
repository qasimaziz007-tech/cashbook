/**
 * Dashboard Module
 * Handles all dashboard functionality including summaries and analytics
 */

const DashboardModule = {
  
  // Initialize dashboard
  init: function() {
    console.log('📊 Initializing Dashboard Module');
    this.bindEvents();
  },

  // Bind dashboard events
  bindEvents: function() {
    // Filter events
    const filterElements = ['filterStart', 'filterEnd', 'filterCategory', 'filterAccount', 'filterType'];
    filterElements.forEach(id => {
      const element = document.getElementById(id);
      if (element) {
        element.addEventListener('change', () => this.applyFilters(true));
      }
    });
  },

  // Load complete dashboard
  loadDashboard: function() {
    this.loadAccountSummary();
    this.loadDashboardSummary(); 
    this.loadDashboardTransactions();
    this.loadTodaySummary();
    this.populateFilterDropdowns();
  },

  // Load today's summary
  loadTodaySummary: function() {
    const today = new Date().toISOString().split('T')[0];
    const todayTransactions = window.appState.transactions.filter(t => t.date === today);
    
    let todayIncome = 0;
    let todayExpense = 0;
    
    todayTransactions.forEach(t => {
      const amount = parseFloat(t.amount || 0);
      if (t.type === 'income') {
        todayIncome += amount;
      } else {
        todayExpense += amount;
      }
    });
    
    const todayNet = todayIncome - todayExpense;
    
    const todaySummaryEl = document.getElementById('todaySummary');
    if (!todaySummaryEl) return;
    
    todaySummaryEl.innerHTML = `
      <div class="card" style="min-width:200px;background:linear-gradient(135deg,#f0f9ff,#e0f2fe);border:1px solid #0ea5e9">
        <div style="font-size:12px;color:#0c4a6e;margin-bottom:6px">
          <i class="fa-solid fa-calendar-day"></i> Today's Income
        </div>
        <div class="today-positive-amount" style="font-size:18px;font-weight:700">${CashBookUtils.formatCurrency(todayIncome)}</div>
      </div>
      <div class="card" style="min-width:200px;background:linear-gradient(135deg,#fef7cd,#fde68a);border:1px solid #f59e0b">
        <div style="font-size:12px;color:#92400e;margin-bottom:6px">
          <i class="fa-solid fa-calendar-day"></i> Today's Expense
        </div>
        <div class="today-negative-amount" style="font-size:18px;font-weight:700">${CashBookUtils.formatCurrency(todayExpense)}</div>
      </div>
      <div class="card" style="min-width:200px;background:linear-gradient(135deg,#f3e8ff,#e9d5ff);border:1px solid #8b5cf6">
        <div style="font-size:12px;color:#6b21a8;margin-bottom:6px">
          <i class="fa-solid fa-calculator"></i> Today's Net
        </div>
        <div class="${todayNet >= 0 ? 'today-positive-amount' : 'today-negative-amount'}" style="font-size:18px;font-weight:700">${CashBookUtils.formatCurrency(todayNet)}</div>
      </div>
    `;
  },

  // Load account summary
  loadAccountSummary: function() {
    const filteredTransactions = this.getFilteredTransactions();
    const accountSummary = {};
    
    // Calculate account totals
    filteredTransactions.forEach(t => {
      const account = t.account || 'Unknown';
      if (!accountSummary[account]) {
        accountSummary[account] = { income: 0, expense: 0 };
      }
      
      const amount = parseFloat(t.amount || 0);
      if (t.type === 'income') {
        accountSummary[account].income += amount;
      } else {
        accountSummary[account].expense += amount;
      }
    });
    
    // Render account summary
    const accountSummaryEl = document.getElementById('accountSummary');
    if (!accountSummaryEl) return;
    
    accountSummaryEl.innerHTML = '';
    
    Object.keys(accountSummary).forEach(account => {
      const data = accountSummary[account];
      const net = data.income - data.expense;
      
      const cardHtml = `
        <div class="card" style="min-width:200px">
          <div style="font-size:12px;color:#6b7280;margin-bottom:8px">
            <i class="fa-solid fa-building"></i> ${account}
          </div>
          <div style="font-size:14px;margin-bottom:4px">
            <span class="positive-amount">↗ ${CashBookUtils.formatCurrency(data.income)}</span>
          </div>
          <div style="font-size:14px;margin-bottom:8px">
            <span class="negative-amount">↘ ${CashBookUtils.formatCurrency(data.expense)}</span>
          </div>
          <hr style="margin:8px 0;border-color:#f3f4f6">
          <div style="font-size:12px;color:#6b7280">Net Balance</div>
          <div class="${net >= 0 ? 'positive-amount' : 'negative-amount'}" style="font-size:20px;font-weight:800">${CashBookUtils.formatCurrency(net)}</div>
        </div>
      `;
      
      accountSummaryEl.innerHTML += cardHtml;
    });
  },

  // Load main dashboard summary
  loadDashboardSummary: function() {
    const filteredTransactions = this.getFilteredTransactions();
    let totalIncome = 0;
    let totalExpense = 0;
    
    filteredTransactions.forEach(t => {
      const amount = parseFloat(t.amount || 0);
      if (t.type === 'income') {
        totalIncome += amount;
      } else {
        totalExpense += amount;
      }
    });
    
    const net = totalIncome - totalExpense;
    
    const dashboardSummaryEl = document.getElementById('dashboardSummary');
    if (!dashboardSummaryEl) return;
    
    dashboardSummaryEl.innerHTML = `
      <div class="card" style="min-width:200px;background:linear-gradient(135deg,#dcfce7,#bbf7d0);border:1px solid #22c55e">
        <div style="font-size:12px;color:#16a34a;margin-bottom:8px">
          <i class="fa-solid fa-arrow-trend-up"></i> Total Income
        </div>
        <div class="positive-amount" style="font-size:20px;font-weight:800">${CashBookUtils.formatCurrency(totalIncome)}</div>
        <div style="font-size:10px;color:#16a34a;margin-top:4px">
          ${filteredTransactions.filter(t => t.type === 'income').length} transactions
        </div>
      </div>
      <div class="card" style="min-width:200px;background:linear-gradient(135deg,#fee2e2,#fecaca);border:1px solid #ef4444">
        <div style="font-size:12px;color:#dc2626;margin-bottom:8px">
          <i class="fa-solid fa-arrow-trend-down"></i> Total Expense
        </div>
        <div class="negative-amount" style="font-size:20px;font-weight:800">${CashBookUtils.formatCurrency(totalExpense)}</div>
        <div style="font-size:10px;color:#dc2626;margin-top:4px">
          ${filteredTransactions.filter(t => t.type === 'expense').length} transactions
        </div>
      </div>
      <div class="card" style="min-width:200px;background:linear-gradient(135deg,#dbeafe,#bfdbfe);border:1px solid #3b82f6">
        <div style="font-size:12px;color:#1d4ed8;margin-bottom:8px">
          <i class="fa-solid fa-balance-scale"></i> Net Amount
        </div>
        <div class="${net >= 0 ? 'positive-amount' : 'negative-amount'}" style="font-size:20px;font-weight:800">${CashBookUtils.formatCurrency(net)}</div>
        <div style="font-size:10px;color:#1d4ed8;margin-top:4px">
          ${net >= 0 ? 'Profit' : 'Loss'} ${totalIncome > 0 ? '(' + ((net / totalIncome) * 100).toFixed(1) + '%)' : ''}
        </div>
      </div>
    `;
  },

  // Load dashboard transactions (recent 50)
  loadDashboardTransactions: function() {
    const filteredTransactions = this.getFilteredTransactions();
    const limitedTransactions = filteredTransactions.slice(0, 50);
    
    const tbody = document.querySelector('#dashboardTransactionsTable tbody');
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    if (limitedTransactions.length === 0) {
      const row = document.createElement('tr');
      row.innerHTML = '<td colspan="8" style="text-align:center;color:#6b7280;padding:20px">No transactions to show</td>';
      tbody.appendChild(row);
      return;
    }
    
    limitedTransactions.forEach(t => {
      const row = document.createElement('tr');
      row.innerHTML = `
        <td>${CashBookUtils.formatDisplayDate(t.date)}</td>
        <td>${t.category || ''}</td>
        <td>${t.transactionId || '-'}</td>
        <td>${t.vendor || '-'}</td>
        <td>${t.account || ''}</td>
        <td class="${t.type === 'income' ? 'income' : 'expense'}">${CashBookUtils.formatCurrency(t.amount)}</td>
        <td style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${t.description || '-'}</td>
        <td class="${t.type === 'income' ? 'income' : 'expense'}" style="text-transform:capitalize">${t.type || ''}</td>
      `;
      tbody.appendChild(row);
    });
  },

  // Get filtered transactions
  getFilteredTransactions: function() {
    if (!window.appState.transactions) return [];
    
    let filtered = [...window.appState.transactions];
    
    // Apply filters
    const startDate = document.getElementById('filterStart')?.value;
    const endDate = document.getElementById('filterEnd')?.value;
    const category = document.getElementById('filterCategory')?.value;
    const account = document.getElementById('filterAccount')?.value;
    const type = document.getElementById('filterType')?.value;
    
    if (startDate || endDate) {
      filtered = CashBookUtils.filterByDateRange(filtered, startDate, endDate);
    }
    
    if (category) {
      filtered = filtered.filter(t => t.category === category);
    }
    
    if (account) {
      filtered = filtered.filter(t => t.account === account);
    }
    
    if (type) {
      filtered = filtered.filter(t => t.type === type);
    }
    
    return CashBookUtils.sortByDate(filtered, true);
  },

  // Populate filter dropdowns
  populateFilterDropdowns: function() {
    const categorySelect = document.getElementById('filterCategory');
    const accountSelect = document.getElementById('filterAccount');
    
    if (categorySelect && window.appState.categories) {
      categorySelect.innerHTML = '<option value="">All Categories</option>';
      window.appState.categories.forEach(c => {
        categorySelect.innerHTML += `<option value="${c}">${c}</option>`;
      });
    }
    
    if (accountSelect && window.appState.accounts) {
      accountSelect.innerHTML = '<option value="">All Accounts</option>';
      window.appState.accounts.forEach(a => {
        accountSelect.innerHTML += `<option value="${a}">${a}</option>`;
      });
    }
  },

  // Apply filters
  applyFilters: function(updateDashboard = false) {
    if (updateDashboard) {
      this.loadAccountSummary();
      this.loadDashboardSummary();
      this.loadDashboardTransactions();
    }
  },

  // Clear filters
  clearFilters: function() {
    const filterElements = ['filterStart', 'filterEnd', 'filterCategory', 'filterAccount', 'filterType'];
    filterElements.forEach(id => {
      const element = document.getElementById(id);
      if (element) element.value = '';
    });
    this.applyFilters(true);
  }
};

// Global functions for backwards compatibility
function loadDashboard() {
  DashboardModule.loadDashboard();
}

function loadAccountSummary() {
  DashboardModule.loadAccountSummary();
}

function loadDashboardSummary() {
  DashboardModule.loadDashboardSummary();
}

function loadTodaySummary() {
  DashboardModule.loadTodaySummary();
}

function loadDashboardTransactions() {
  DashboardModule.loadDashboardTransactions();
}

function refreshPerformanceDashboard() {
  DashboardModule.loadDashboard();
}

function populateFilterDropdowns() {
  DashboardModule.populateFilterDropdowns();
}

function applyFilters() {
  DashboardModule.applyFilters(true);
}

function clearFilters() {
  DashboardModule.clearFilters();
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = DashboardModule;
}