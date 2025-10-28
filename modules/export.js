/**
 * Export Module
 * Handles all export functionality (Excel, PDF, Print)
 */

const ExportModule = {
  
  // Initialize export module
  init: function() {
    console.log('📄 Initializing Export Module');
    this.bindEvents();
  },

  // Bind export events
  bindEvents: function() {
    // Add export button listeners if needed
    const exportBtn = document.getElementById('exportBtn');
    const exportPdfBtn = document.getElementById('exportPdfBtn');
    
    if (exportBtn) {
      exportBtn.addEventListener('click', () => this.exportExcel());
    }
    
    if (exportPdfBtn) {
      exportPdfBtn.addEventListener('click', () => this.exportPDF());
    }
  },

  // Export transactions to Excel
  exportExcel: function() {
    try {
      if (typeof XLSX === 'undefined') {
        alert('Excel export library not loaded');
        return;
      }

      // Get filtered transactions
      const filteredTransactions = this.getFilteredTransactions();
      
      const data = filteredTransactions.map(t => ({
        Date: CashBookUtils.formatDisplayDate(t.date),
        Category: t.category,
        ID: t.transactionId || '',
        Vendor: t.vendor || '',
        Account: t.account,
        Amount: CashBookUtils.formatExportAmount(t.amount),
        Description: t.description || '',
        Type: t.type,
        'Created By': t.createdBy || 'anonymous',
        'Edited By': t.editedBy || ''
      }));
      
      const worksheet = XLSX.utils.json_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Transactions');
      XLSX.writeFile(workbook, `transactions_${new Date().toISOString().split('T')[0]}.xlsx`);
      
      CashBookUtils.showToast('Excel file exported successfully');
    } catch (error) {
      console.error('Excel export error:', error);
      CashBookUtils.showToast('Excel export failed', 'error');
    }
  },

  // Export transactions to PDF
  exportPDF: function() {
    try {
      const { jsPDF } = window.jspdf || {};
      if (!jsPDF) {
        alert('PDF export library not loaded');
        return;
      }

      const doc = new jsPDF();
      const filteredTransactions = this.getFilteredTransactions();

      // Header
      doc.setFontSize(16);
      doc.text('Esthetics Auto - Transaction Report', 105, 15, { align: 'center' });
      
      // Filters info
      let filtersText = 'Filters: ';
      const startDate = document.getElementById('filterStart')?.value;
      const endDate = document.getElementById('filterEnd')?.value;
      const category = document.getElementById('filterCategory')?.value;
      const account = document.getElementById('filterAccount')?.value;
      
      if (startDate || endDate) {
        filtersText += `Date: ${startDate || 'Any'} to ${endDate || 'Any'} `;
      }
      if (category) filtersText += `Category: ${category} `;
      if (account) filtersText += `Account: ${account} `;
      
      doc.setFontSize(10);
      doc.text(filtersText, 10, 25);
      doc.text(`Generated: ${new Date().toLocaleString()}`, 10, 30);
      doc.text(`Total Records: ${filteredTransactions.length}`, 10, 35);

      // Table data
      const tableData = filteredTransactions.slice(0, 25).map(t => [
        CashBookUtils.formatDisplayDate(t.date),
        t.category || '',
        t.transactionId || '',
        t.vendor || '',
        t.account || '',
        CashBookUtils.formatExportAmount(t.amount),
        t.type || ''
      ]);

      // Create table
      doc.autoTable({
        startY: 40,
        head: [['Date', 'Category', 'ID', 'Vendor', 'Account', 'Amount', 'Type']],
        body: tableData,
        styles: { fontSize: 8 },
        headStyles: { fillColor: [11, 59, 109] },
        alternateRowStyles: { fillColor: [248, 249, 250] }
      });

      doc.save(`transactions_${new Date().toISOString().split('T')[0]}.pdf`);
      CashBookUtils.showToast('PDF file exported successfully');
    } catch (error) {
      console.error('PDF export error:', error);
      CashBookUtils.showToast('PDF export failed', 'error');
    }
  },

  // Export employees to Excel
  exportEmployeesExcel: function() {
    try {
      if (typeof XLSX === 'undefined') {
        alert('Excel export library not loaded');
        return;
      }

      const employees = window.appState.employees || [];
      
      const data = employees.map(emp => ({
        Name: emp.name,
        Position: emp.position,
        'Salary (AED)': CashBookUtils.formatExportAmount(emp.salary),
        Phone: emp.phone || '',
        Email: emp.email || '',
        'Emirates ID': emp.emiratesId || '',
        'Passport Number': emp.passportNumber || '',
        'Visa Expiry': CashBookUtils.formatDate(emp.visaExpiry),
        'Passport Expiry': CashBookUtils.formatDate(emp.passportExpiry),
        'Joining Date': CashBookUtils.formatDate(emp.joiningDate),
        Status: emp.status || 'active'
      }));
      
      const worksheet = XLSX.utils.json_to_sheet(data);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Employees');
      XLSX.writeFile(workbook, `employees_${new Date().toISOString().split('T')[0]}.xlsx`);
      
      CashBookUtils.showToast('Employee Excel file exported successfully');
    } catch (error) {
      console.error('Employee Excel export error:', error);
      CashBookUtils.showToast('Employee Excel export failed', 'error');
    }
  },

  // Export employees to PDF
  exportEmployeesPDF: function() {
    try {
      const { jsPDF } = window.jspdf || {};
      if (!jsPDF) {
        alert('PDF export library not loaded');
        return;
      }

      const doc = new jsPDF();
      const employees = window.appState.employees || [];

      // Header
      doc.setFontSize(16);
      doc.text('Esthetics Auto - Employee Report', 105, 15, { align: 'center' });
      
      doc.setFontSize(10);
      doc.text(`Generated: ${new Date().toLocaleString()}`, 10, 25);
      doc.text(`Total Employees: ${employees.length}`, 10, 30);

      // Table data
      const tableData = employees.map(emp => [
        emp.name,
        emp.position,
        CashBookUtils.formatCurrency(emp.salary),
        CashBookUtils.formatDate(emp.visaExpiry),
        CashBookUtils.formatDate(emp.passportExpiry),
        emp.status?.toUpperCase() || 'ACTIVE'
      ]);

      // Create table
      doc.autoTable({
        startY: 35,
        head: [['Name', 'Position', 'Salary', 'Visa Expiry', 'Passport Expiry', 'Status']],
        body: tableData,
        styles: { fontSize: 8 },
        headStyles: { fillColor: [11, 59, 109] },
        alternateRowStyles: { fillColor: [248, 249, 250] }
      });

      doc.save(`employees_${new Date().toISOString().split('T')[0]}.pdf`);
      CashBookUtils.showToast('Employee PDF file exported successfully');
    } catch (error) {
      console.error('Employee PDF export error:', error);
      CashBookUtils.showToast('Employee PDF export failed', 'error');
    }
  },

  // Get filtered transactions for general export
  getFilteredTransactions: function() {
    if (!window.appState.transactions) return [];
    
    let filtered = [...window.appState.transactions];
    
    // Apply filters if dashboard is available
    if (typeof DashboardModule !== 'undefined' && DashboardModule.getFilteredTransactions) {
      return DashboardModule.getFilteredTransactions();
    }
    
    return CashBookUtils.sortByDate(filtered, true);
  },

  // Excel export for vehicle reports
  exportVehicleReportExcel: function() {
    try {
      console.log('📊 Starting Excel export for vehicle report');
      
      // Get current filter values
      const vehicleId = document.getElementById('vrVehicleId')?.value?.trim() || '';
      const startDate = document.getElementById('vrStartDate')?.value || '';
      const endDate = document.getElementById('vrEndDate')?.value || '';
      
      // Get filtered data
      const transactions = this.getFilteredVehicleTransactions(vehicleId, startDate, endDate);
      
      if (transactions.length === 0) {
        CashBookUtils.showToast('No vehicle transactions found for the selected criteria.', 'warning');
        return;
      }
      
      // Prepare transaction data
      const transactionData = this.prepareTransactionData(transactions);
      
      // Prepare summary data
      const summaryData = this.prepareSummaryData(transactions, vehicleId, startDate, endDate);
      
      // Prepare vehicle analysis data
      const vehicleAnalysisData = this.prepareVehicleAnalysisData(transactions);
      
      // Create workbook
      const workbook = XLSX.utils.book_new();
      
      // Add sheets
      const transactionSheet = XLSX.utils.json_to_sheet(transactionData);
      const summarySheet = XLSX.utils.json_to_sheet([summaryData]);
      const analysisSheet = XLSX.utils.aoa_to_sheet(vehicleAnalysisData);
      
      XLSX.utils.book_append_sheet(workbook, transactionSheet, 'Transactions');
      XLSX.utils.book_append_sheet(workbook, summarySheet, 'Summary');
      XLSX.utils.book_append_sheet(workbook, analysisSheet, 'Vehicle Analysis');
      
      // Generate filename
      const filename = `vehicle_report_${vehicleId || 'all'}_${new Date().toISOString().split('T')[0]}.xlsx`;
      
      // Save file
      XLSX.writeFile(workbook, filename);
      
      CashBookUtils.showToast('Excel file exported successfully!', 'success');
      
    } catch (error) {
      console.error('Excel export failed:', error);
      CashBookUtils.showToast('Excel export failed. Please try again.', 'error');
    }
  },

  // PDF export for vehicle reports
  exportVehicleReportPDF: function() {
    try {
      console.log('📋 Starting PDF export for vehicle report');
      
      const { jsPDF } = window.jspdf || {};
      if (!jsPDF) {
        CashBookUtils.showToast('PDF library not available', 'error');
        return;
      }
      
      // Get current filter values
      const vehicleId = document.getElementById('vrVehicleId')?.value?.trim() || '';
      const startDate = document.getElementById('vrStartDate')?.value || '';
      const endDate = document.getElementById('vrEndDate')?.value || '';
      
      // Get filtered data
      const transactions = this.getFilteredVehicleTransactions(vehicleId, startDate, endDate);
      
      if (transactions.length === 0) {
        CashBookUtils.showToast('No vehicle transactions found for the selected criteria.', 'warning');
        return;
      }
      
      // Create PDF
      const doc = new jsPDF('p', 'pt', 'a4');
      
      // Add header
      this.addPDFHeader(doc, vehicleId, startDate, endDate);
      
      // Add summary section
      const summaryHeight = this.addPDFSummary(doc, transactions, vehicleId);
      
      // Add transactions table
      this.addPDFTransactionsTable(doc, transactions, summaryHeight);
      
      // Save PDF
      const filename = `vehicle_report_${vehicleId || 'all'}_${new Date().toISOString().split('T')[0]}.pdf`;
      doc.save(filename);
      
      CashBookUtils.showToast('PDF exported successfully!', 'success');
      
    } catch (error) {
      console.error('PDF export failed:', error);
      CashBookUtils.showToast('PDF export failed. Please try again.', 'error');
    }
  },

  // Print vehicle report
  printVehicleReport: function() {
    try {
      console.log('🖨️ Starting print for vehicle report');
      
      // Get current filter values
      const vehicleId = document.getElementById('vrVehicleId')?.value?.trim() || '';
      const startDate = document.getElementById('vrStartDate')?.value || '';
      const endDate = document.getElementById('vrEndDate')?.value || '';
      
      // Get filtered data
      const transactions = this.getFilteredVehicleTransactions(vehicleId, startDate, endDate);
      
      if (transactions.length === 0) {
        CashBookUtils.showToast('No data to print', 'warning');
        return;
      }
      
      // Create print window
      const printWindow = window.open('', '_blank');
      const printContent = this.generatePrintHTML(transactions, vehicleId, startDate, endDate);
      
      printWindow.document.write(printContent);
      printWindow.document.close();
      printWindow.print();
      
    } catch (error) {
      console.error('Print failed:', error);
      CashBookUtils.showToast('Print failed. Please try again.', 'error');
    }
  },

  // Helper: Get filtered vehicle transactions
  getFilteredVehicleTransactions: function(vehicleId, startDate, endDate) {
    if (!window.state || !window.state.transactions) return [];
    
    let filtered = [...window.state.transactions];
    
    // Filter by date range
    if (startDate || endDate) {
      filtered = CashBookUtils.filterByDateRange(filtered, startDate, endDate);
    }
    
    // Filter by vehicle ID if specified
    if (vehicleId) {
      const vid = vehicleId.toLowerCase();
      filtered = filtered.filter(txn => {
        const transactionId = (txn.transactionId || '').toLowerCase();
        const vendor = (txn.vendor || '').toLowerCase();
        const description = (txn.description || '').toLowerCase();
        const account = (txn.account || '').toLowerCase();
        const remarks = (txn.remarks || '').toLowerCase();
        
        return transactionId.includes(vid) ||
               vendor.includes(vid) ||
               description.includes(vid) ||
               account.includes(vid) ||
               remarks.includes(vid) ||
               CashBookUtils.extractVehicleId(txn).toLowerCase().includes(vid);
      });
    }
    
    return CashBookUtils.sortByDate(filtered, true);
  },

  // Helper: Prepare transaction data for Excel
  prepareTransactionData: function(transactions) {
    return transactions.map(t => ({
      Date: CashBookUtils.formatDisplayDate(t.date),
      Category: t.category || '',
      'Vehicle ID': CashBookUtils.extractVehicleId(t),
      Vendor: t.vendor || '',
      Account: t.account || '',
      'Amount (AED)': CashBookUtils.formatExportAmount(t.amount),
      Description: t.description || '',
      Type: (t.type || '').charAt(0).toUpperCase() + (t.type || '').slice(1),
      'Created By': t.createdBy || 'anonymous',
      'Created At': t.createdAt ? CashBookUtils.formatDateTime(t.createdAt) : '',
      'Edited By': t.editedBy || '',
      'Edited At': t.editedAt ? CashBookUtils.formatDateTime(t.editedAt) : ''
    }));
  },

  // Helper: Prepare summary data for Excel
  prepareSummaryData: function(transactions, vehicleId, startDate, endDate) {
    const income = CashBookUtils.calculateSum(transactions.filter(t => t.type === 'income'));
    const expense = CashBookUtils.calculateSum(transactions.filter(t => t.type === 'expense'));
    const net = income - expense;
    
    const vehicleIds = new Set();
    const categories = new Set();
    transactions.forEach(t => {
      const vId = CashBookUtils.extractVehicleId(t);
      if (vId && vId !== 'Empty') vehicleIds.add(vId);
      if (t.category) categories.add(t.category);
    });
    
    return {
      'Report Type': 'Vehicle Report',
      'Vehicle': vehicleId || 'All Vehicles',
      'Start Date': startDate || '-',
      'End Date': endDate || '-',
      'Total Transactions': transactions.length,
      'Total Income (AED)': income,
      'Total Expense (AED)': expense,
      'Net Profit/Loss (AED)': net,
      'Unique Vehicles': vehicleIds.size,
      'Categories Used': categories.size,
      'Export Date': new Date().toISOString(),
      'Exported By': window.state?.currentUser?.username || 'anonymous'
    };
  },

  // Helper: Prepare vehicle analysis data for Excel
  prepareVehicleAnalysisData: function(transactions) {
    const vehicleStats = {};
    
    transactions.forEach(t => {
      const vehicleId = CashBookUtils.extractVehicleId(t);
      
      if (!vehicleStats[vehicleId]) {
        vehicleStats[vehicleId] = {
          totalIncome: 0,
          totalExpense: 0,
          transactionCount: 0,
          categories: new Set()
        };
      }
      
      const amount = parseFloat(t.amount || 0);
      if (t.type === 'income') {
        vehicleStats[vehicleId].totalIncome += amount;
      } else {
        vehicleStats[vehicleId].totalExpense += amount;
      }
      
      vehicleStats[vehicleId].transactionCount++;
      vehicleStats[vehicleId].categories.add(t.category || 'Other');
    });
    
    const analysisRows = [['Vehicle ID', 'Total Income (AED)', 'Total Expense (AED)', 'Net Profit/Loss (AED)', 'Transaction Count', 'Categories Used', 'Profit Margin (%)']];
    
    Object.keys(vehicleStats).forEach(vehicleId => {
      const stats = vehicleStats[vehicleId];
      const net = stats.totalIncome - stats.totalExpense;
      const profitMargin = stats.totalIncome > 0 ? ((net / stats.totalIncome) * 100) : 0;
      
      analysisRows.push([
        vehicleId,
        stats.totalIncome,
        stats.totalExpense,
        net,
        stats.transactionCount,
        stats.categories.size,
        profitMargin.toFixed(2)
      ]);
    });
    
    return analysisRows;
  },

  // Helper: Add PDF header
  addPDFHeader: function(doc, vehicleId, startDate, endDate) {
    // Header background
    doc.setFillColor(11, 59, 109);
    doc.rect(40, 30, 515, 50, 'F');
    
    // Header text
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(18);
    doc.text('🚗 VEHICLE REPORT', 50, 60);
    
    // Reset text color
    doc.setTextColor(0, 0, 0);
    
    // Report details
    doc.setFontSize(12);
    doc.setFont(undefined, 'bold');
    doc.text('Report Details:', 40, 110);
    
    doc.setFont(undefined, 'normal');
    doc.setFontSize(11);
    doc.text(`Vehicle: ${vehicleId || 'All Vehicles'}`, 50, 130);
    
    if (startDate || endDate) {
      doc.text(`Date Range: ${startDate || 'Start'} to ${endDate || 'End'}`, 50, 145);
    }
    
    doc.text(`Generated: ${new Date().toLocaleString()}`, 50, 160);
    
    return 180; // Return Y position for next content
  },

  // Helper: Add PDF summary
  addPDFSummary: function(doc, transactions, vehicleId) {
    const income = CashBookUtils.calculateSum(transactions.filter(t => t.type === 'income'));
    const expense = CashBookUtils.calculateSum(transactions.filter(t => t.type === 'expense'));
    const net = income - expense;
    
    const vehicleIds = new Set();
    transactions.forEach(t => {
      const vId = CashBookUtils.extractVehicleId(t);
      if (vId && vId !== 'Empty') vehicleIds.add(vId);
    });
    
    let yPos = 200;
    
    // Summary section header
    doc.setFontSize(12);
    doc.setFont(undefined, 'bold');
    doc.text('Financial Summary:', 40, yPos);
    yPos += 20;
    
    // Summary data
    doc.setFont(undefined, 'normal');
    doc.setFontSize(11);
    
    // Income
    doc.setTextColor(34, 197, 94); // Green
    doc.text(`Total Income: ${CashBookUtils.formatCurrency(income)}`, 50, yPos);
    yPos += 18;
    
    // Expense
    doc.setTextColor(239, 68, 68); // Red
    doc.text(`Total Expense: ${CashBookUtils.formatCurrency(expense)}`, 50, yPos);
    yPos += 18;
    
    // Net
    doc.setTextColor(net >= 0 ? 34 : 239, net >= 0 ? 197 : 68, net >= 0 ? 94 : 68);
    doc.text(`Net Amount: ${CashBookUtils.formatCurrency(net)}`, 50, yPos);
    yPos += 18;
    
    // Reset color
    doc.setTextColor(0, 0, 0);
    doc.text(`Total Transactions: ${transactions.length}`, 50, yPos);
    yPos += 18;
    
    doc.text(`Unique Vehicles: ${vehicleIds.size}`, 50, yPos);
    yPos += 30;
    
    return yPos;
  },

  // Helper: Add PDF transactions table
  addPDFTransactionsTable: function(doc, transactions, startY) {
    const tableData = transactions.slice(0, 50).map(t => [
      CashBookUtils.formatDisplayDate(t.date || ''),
      t.category || '',
      CashBookUtils.extractVehicleId(t),
      t.vendor || '',
      t.account || '',
      CashBookUtils.formatExportAmount(t.amount || 0),
      t.type || ''
    ]);
    
    doc.autoTable({
      startY: startY,
      head: [['Date', 'Category', 'Vehicle ID', 'Vendor', 'Account', 'Amount (AED)', 'Type']],
      body: tableData,
      styles: { fontSize: 9 },
      headStyles: { fillColor: [59, 130, 246] },
      alternateRowStyles: { fillColor: [248, 250, 252] }
    });
  },

  // Helper: Generate print HTML
  generatePrintHTML: function(transactions, vehicleId, startDate, endDate) {
    const income = CashBookUtils.calculateSum(transactions.filter(t => t.type === 'income'));
    const expense = CashBookUtils.calculateSum(transactions.filter(t => t.type === 'expense'));
    const net = income - expense;
    
    const summaryData = {
      income: CashBookUtils.formatCurrency(income),
      expense: CashBookUtils.formatCurrency(expense),
      net: CashBookUtils.formatCurrency(net),
      count: transactions.length.toLocaleString()
    };
    
    return `
      <html>
      <head>
        <title>Vehicle Report - ${vehicleId || 'All Vehicles'}</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; line-height: 1.6; }
          h1 { color: #1f2937; border-bottom: 2px solid #3b82f6; padding-bottom: 10px; margin-bottom: 20px; }
          .header-info { background: #f8fafc; padding: 16px; border-radius: 8px; margin-bottom: 20px; }
          .summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 16px; margin: 20px 0; }
          .summary-item { border: 1px solid #e2e8f0; padding: 16px; border-radius: 8px; text-align: center; }
          .summary-label { font-size: 12px; color: #6b7280; margin-bottom: 8px; }
          .summary-value { font-size: 18px; font-weight: 700; }
          table { width: 100%; border-collapse: collapse; margin-top: 20px; }
          th, td { border: 1px solid #e2e8f0; padding: 8px; text-align: left; font-size: 12px; }
          th { background-color: #f8fafc; font-weight: 600; }
          .positive-amount { color: #16a34a; font-weight: 600; }
          .negative-amount { color: #dc2626; font-weight: 600; }
          @media print { 
            body { margin: 0; } 
            .no-print { display: none; }
          }
        </style>
      </head>
      <body>
        <h1>🚗 Vehicle Report</h1>
        
        <div class="header-info">
          <p><strong>Vehicle:</strong> ${vehicleId || 'All Vehicles'}</p>
          <p><strong>Date Range:</strong> ${startDate || 'All Time'} ${endDate ? 'to ' + endDate : ''}</p>
          <p><strong>Generated:</strong> ${new Date().toLocaleString()}</p>
        </div>
        
        <div class="summary">
          <div class="summary-item">
            <div class="summary-label">Total Income</div>
            <div class="summary-value positive-amount">${summaryData.income}</div>
          </div>
          <div class="summary-item">
            <div class="summary-label">Total Expense</div>
            <div class="summary-value negative-amount">${summaryData.expense}</div>
          </div>
          <div class="summary-item">
            <div class="summary-label">Net Amount</div>
            <div class="summary-value ${net >= 0 ? 'positive-amount' : 'negative-amount'}">${summaryData.net}</div>
          </div>
          <div class="summary-item">
            <div class="summary-label">Total Records</div>
            <div class="summary-value">${summaryData.count}</div>
          </div>
        </div>
        
        <table>
          <thead>
            <tr>
              <th>Date</th>
              <th>Category</th>
              <th>Vehicle ID</th>
              <th>Vendor</th>
              <th>Account</th>
              <th>Amount (AED)</th>
              <th>Description</th>
              <th>Type</th>
            </tr>
          </thead>
          <tbody>
            ${transactions.map(t => {
              const vehicleId = CashBookUtils.extractVehicleId(t);
              const amountClass = t.type === 'income' ? 'positive-amount' : 'negative-amount';
              
              return `
                <tr>
                  <td>${CashBookUtils.formatDisplayDate(t.date || '')}</td>
                  <td>${t.category || ''}</td>
                  <td style="font-family: monospace; font-weight: 600;">${vehicleId}</td>
                  <td>${t.vendor || '-'}</td>
                  <td>${t.account || ''}</td>
                  <td class="${amountClass}">${CashBookUtils.formatExportAmount(t.amount || 0)}</td>
                  <td>${t.description || '-'}</td>
                  <td style="text-transform: capitalize;">${t.type || ''}</td>
                </tr>
              `;
            }).join('')}
          </tbody>
        </table>
        
        <div style="margin-top: 30px; text-align: center; color: #6b7280; font-size: 12px;">
          <p>Generated by Esthetics Auto CashBook System</p>
        </div>
      </body>
      </html>
    `;
  }
};

// Global functions for backwards compatibility
function exportExcel() {
  ExportModule.exportExcel();
}

function exportPDF() {
  ExportModule.exportPDF();
}

function exportEmployeesExcel() {
  ExportModule.exportEmployeesExcel();
}

function exportEmployeesPDF() {
  ExportModule.exportEmployeesPDF();
}

function exportVehicleReportExcel() {
  ExportModule.exportVehicleReportExcel();
}

function exportVehicleReportPDF() {
  ExportModule.exportVehicleReportPDF();
}

function printVehicleReport() {
  ExportModule.printVehicleReport();
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = ExportModule;
}