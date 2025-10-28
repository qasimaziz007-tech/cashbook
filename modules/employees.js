/**
 * Employees Module
 * Handles all employee management functionality
 */

const EmployeesModule = {
  
  // Initialize employees module
  init: function() {
    console.log('👥 Initializing Employees Module');
    this.bindEvents();
  },

  // Bind employee events
  bindEvents: function() {
    const employeeForm = document.getElementById('employeeForm');
    if (employeeForm) {
      employeeForm.addEventListener('submit', (e) => {
        e.preventDefault();
        this.saveEmployee();
      });
    }

    // Photo upload preview
    const photoInput = document.getElementById('empPhoto');
    if (photoInput) {
      photoInput.addEventListener('change', (e) => {
        this.previewPhoto(e.target);
      });
    }
  },

  // Load all employees
  loadEmployees: function() {
    this.loadEmployeesList();
    this.loadEmployeeDropdowns();
    this.checkVisaExpiry();
  },

  // Load employees list table
  loadEmployeesList: function() {
    const tbody = document.querySelector('#employeesTable tbody');
    if (!tbody) return;
    
    tbody.innerHTML = '';
    
    if (!window.appState.employees || window.appState.employees.length === 0) {
      const row = document.createElement('tr');
      row.innerHTML = '<td colspan="7" style="text-align:center;color:#6b7280;padding:20px">No employees found</td>';
      tbody.appendChild(row);
      return;
    }
    
    window.appState.employees.forEach((emp, index) => {
      const row = document.createElement('tr');
      
      // Calculate visa expiry status
      const visaStatus = this.getVisaExpiryStatus(emp.visaExpiry);
      const passportStatus = this.getVisaExpiryStatus(emp.passportExpiry);
      
      row.innerHTML = `
        <td style="font-weight:600">${emp.name}</td>
        <td>${emp.position}</td>
        <td class="positive-amount">${CashBookUtils.formatCurrency(emp.salary)}</td>
        <td class="${visaStatus.class}">${CashBookUtils.formatDate(emp.visaExpiry)} ${visaStatus.warning}</td>
        <td class="${passportStatus.class}">${CashBookUtils.formatDate(emp.passportExpiry)} ${passportStatus.warning}</td>
        <td class="status-${emp.status}">${emp.status?.toUpperCase()}</td>
        <td>
          <button class="action-btn" onclick="EmployeesModule.viewEmployee(${index})" title="View"><i class="fa-solid fa-eye"></i></button>
          <button class="action-btn" onclick="EmployeesModule.editEmployee(${index})" title="Edit"><i class="fa-solid fa-edit"></i></button>
          <button class="action-btn" onclick="EmployeesModule.deleteEmployee(${index})" title="Delete"><i class="fa-solid fa-trash" style="color:#ef4444"></i></button>
        </td>
      `;
      
      tbody.appendChild(row);
    });
  },

  // Load employee dropdowns for other modules
  loadEmployeeDropdowns: function() {
    const employeeDropdowns = [
      'advanceEmployee', 
      'attendanceEmployee', 
      'payrollEmployee', 
      'filterPayrollEmployee'
    ];
    
    employeeDropdowns.forEach(dropdownId => {
      const dropdown = document.getElementById(dropdownId);
      if (!dropdown) return;
      
      dropdown.innerHTML = '<option value="">Select Employee</option>';
      
      if (window.appState.employees) {
        window.appState.employees.forEach(emp => {
          if (emp.status === 'active') {
            dropdown.innerHTML += `<option value="${emp.id}">${emp.name}</option>`;
          }
        });
      }
    });
  },

  // Check for visa expiry warnings
  checkVisaExpiry: function() {
    const visaRemindersEl = document.getElementById('visaReminders');
    if (!visaRemindersEl) return;
    
    const warnings = [];
    const today = new Date();
    const thirtyDaysFromNow = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000);
    
    if (window.appState.employees) {
      window.appState.employees.forEach(emp => {
        if (emp.status !== 'active') return;
        
        const visaDate = new Date(emp.visaExpiry);
        const passportDate = new Date(emp.passportExpiry);
        
        if (visaDate <= thirtyDaysFromNow) {
          const daysLeft = Math.ceil((visaDate - today) / (1000 * 60 * 60 * 24));
          warnings.push({
            employee: emp.name,
            type: 'Visa',
            date: emp.visaExpiry,
            daysLeft: daysLeft,
            urgent: daysLeft <= 7
          });
        }
        
        if (passportDate <= thirtyDaysFromNow) {
          const daysLeft = Math.ceil((passportDate - today) / (1000 * 60 * 60 * 24));
          warnings.push({
            employee: emp.name,
            type: 'Passport',
            date: emp.passportExpiry,
            daysLeft: daysLeft,
            urgent: daysLeft <= 7
          });
        }
      });
    }
    
    if (warnings.length > 0) {
      visaRemindersEl.innerHTML = `
        <div class="card-title" style="color:#d97706"><i class="fa-solid fa-exclamation-triangle"></i> Expiry Reminders</div>
        ${warnings.map(w => `
          <div class="visa-warning" style="background-color:${w.urgent ? '#fee2e2' : '#fef3c7'};border-left-color:${w.urgent ? '#ef4444' : '#f59e0b'}">
            <strong>${w.employee}</strong> - ${w.type} expires on ${CashBookUtils.formatDate(w.date)}
            ${w.daysLeft > 0 ? `(${w.daysLeft} days left)` : '(EXPIRED)'}
          </div>
        `).join('')}
      `;
      visaRemindersEl.style.display = 'block';
    } else {
      visaRemindersEl.style.display = 'none';
    }
  },

  // Get visa expiry status
  getVisaExpiryStatus: function(expiryDate) {
    if (!expiryDate) return { class: '', warning: '' };
    
    const today = new Date();
    const expiry = new Date(expiryDate);
    const daysLeft = Math.ceil((expiry - today) / (1000 * 60 * 60 * 24));
    
    if (daysLeft <= 0) {
      return { class: 'negative-amount', warning: '(EXPIRED)' };
    } else if (daysLeft <= 7) {
      return { class: 'negative-amount', warning: `(${daysLeft}d left)` };
    } else if (daysLeft <= 30) {
      return { class: 'status-warning', warning: `(${daysLeft}d left)` };
    }
    
    return { class: 'positive-amount', warning: '' };
  },

  // Save employee (add or update)
  saveEmployee: function() {
    const form = document.getElementById('employeeForm');
    const formData = new FormData(form);
    
    // Validate required fields
    const requiredFields = ['empName', 'empPosition', 'empSalary'];
    for (const field of requiredFields) {
      const value = formData.get(field);
      if (!value || (field === 'empSalary' && parseFloat(value) <= 0)) {
        alert(`Please enter a valid ${field.replace('emp', '').toLowerCase()}`);
        return;
      }
    }
    
    const employee = {
      id: CashBookUtils.generateId(),
      name: formData.get('empName'),
      position: formData.get('empPosition'),
      salary: parseFloat(formData.get('empSalary')),
      phone: formData.get('empPhone') || '',
      email: formData.get('empEmail') || '',
      address: formData.get('empAddress') || '',
      emiratesId: formData.get('empEmiratesId') || '',
      passportNumber: formData.get('empPassport') || '',
      visaExpiry: formData.get('empVisaExpiry') || '',
      passportExpiry: formData.get('empPassportExpiry') || '',
      joiningDate: formData.get('empJoiningDate') || new Date().toISOString().split('T')[0],
      status: formData.get('empStatus') || 'active',
      photo: formData.get('empPhoto') || '',
      createdAt: new Date().toISOString(),
      createdBy: window.appState.currentUser?.username || 'anonymous'
    };
    
    // Add to state
    window.appState.employees.push(employee);
    CashBookUtils.LS.set('employees', window.appState.employees);
    
    // Sync to Firebase if available
    if (typeof syncEmployeesToFirestore === 'function') {
      syncEmployeesToFirestore();
    }
    
    // Reset form and reload
    this.resetEmployeeForm();
    this.loadEmployees();
    
    CashBookUtils.showToast('Employee saved successfully');
  },

  // Reset employee form
  resetEmployeeForm: function() {
    const form = document.getElementById('employeeForm');
    if (form) {
      form.reset();
      
      const photoPreview = document.getElementById('empPhotoPreview');
      if (photoPreview) {
        photoPreview.style.display = 'none';
      }
      
      const statusField = document.getElementById('empStatus');
      if (statusField) {
        statusField.value = 'active';
      }
    }
  },

  // Preview employee photo
  previewPhoto: function(input) {
    const preview = document.getElementById('empPhotoPreview');
    if (!preview) return;
    
    if (input.files && input.files[0]) {
      const reader = new FileReader();
      reader.onload = function(e) {
        preview.src = e.target.result;
        preview.style.display = 'block';
      };
      reader.readAsDataURL(input.files[0]);
    } else {
      preview.style.display = 'none';
    }
  },

  // View employee details
  viewEmployee: function(index) {
    const emp = window.appState.employees[index];
    if (!emp) return;
    
    let employeeDetails = `
      <strong>Name:</strong> ${emp.name}<br>
      <strong>Position:</strong> ${emp.position}<br>
      <strong>Salary:</strong> ${CashBookUtils.formatCurrency(emp.salary)}<br>
      <strong>Phone:</strong> ${emp.phone || 'N/A'}<br>
      <strong>Email:</strong> ${emp.email || 'N/A'}<br>
      <strong>Address:</strong> ${emp.address || 'N/A'}<br>
      <strong>Emirates ID:</strong> ${emp.emiratesId || 'N/A'}<br>
      <strong>Passport:</strong> ${emp.passportNumber || 'N/A'}<br>
      <strong>Visa Expiry:</strong> ${CashBookUtils.formatDate(emp.visaExpiry)}<br>
      <strong>Passport Expiry:</strong> ${CashBookUtils.formatDate(emp.passportExpiry)}<br>
      <strong>Joining Date:</strong> ${CashBookUtils.formatDate(emp.joiningDate)}<br>
      <strong>Status:</strong> ${emp.status?.toUpperCase()}<br>
      <strong>Created:</strong> ${CashBookUtils.formatDateTime(emp.createdAt)}
    `;
    
    alert(employeeDetails);
  },

  // Edit employee
  editEmployee: function(index) {
    const emp = window.appState.employees[index];
    if (!emp) return;
    
    // Populate form with employee data
    document.getElementById('empName').value = emp.name;
    document.getElementById('empPosition').value = emp.position;
    document.getElementById('empSalary').value = emp.salary;
    document.getElementById('empPhone').value = emp.phone || '';
    document.getElementById('empEmail').value = emp.email || '';
    document.getElementById('empAddress').value = emp.address || '';
    document.getElementById('empEmiratesId').value = emp.emiratesId || '';
    document.getElementById('empPassport').value = emp.passportNumber || '';
    document.getElementById('empVisaExpiry').value = emp.visaExpiry || '';
    document.getElementById('empPassportExpiry').value = emp.passportExpiry || '';
    document.getElementById('empJoiningDate').value = emp.joiningDate || '';
    document.getElementById('empStatus').value = emp.status || 'active';
    
    // Remove the old employee record
    window.appState.employees.splice(index, 1);
    CashBookUtils.LS.set('employees', window.appState.employees);
    
    this.loadEmployees();
  },

  // Delete employee
  deleteEmployee: function(index) {
    const emp = window.appState.employees[index];
    if (!emp) return;
    
    if (confirm(`Are you sure you want to delete employee: ${emp.name}?`)) {
      window.appState.employees.splice(index, 1);
      CashBookUtils.LS.set('employees', window.appState.employees);
      
      this.loadEmployees();
      CashBookUtils.showToast('Employee deleted');
    }
  }
};

// Global functions for backwards compatibility
function loadEmployees() {
  EmployeesModule.loadEmployees();
}

function saveEmployee() {
  EmployeesModule.saveEmployee();
}

function resetEmployeeForm() {
  EmployeesModule.resetEmployeeForm();
}

function viewEmployee(index) {
  EmployeesModule.viewEmployee(index);
}

function editEmployee(index) {
  EmployeesModule.editEmployee(index);
}

function deleteEmployee(index) {
  EmployeesModule.deleteEmployee(index);
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = EmployeesModule;
}