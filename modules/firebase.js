/**
 * Firebase Module
 * Handles all Firebase and Firestore operations
 */

const FirebaseModule = {
  
  // Firebase app and services
  app: null,
  db: null,
  auth: null,
  initialized: false,
  
  // Initialize Firebase
  init: function() {
    try {
      console.log('🔥 Initializing Firebase Module');
      
      // Check if Firebase is available
      if (typeof firebase === 'undefined') {
        console.warn('Firebase SDK not loaded');
        return false;
      }
      
      // Firebase config
      const firebaseConfig = {
        apiKey: "AIzaSyD_Qp5F7kk9cZrQxNWBLL2rAmCiFJmI_rM",
        authDomain: "esthetics-auto-cashbook.firebaseapp.com",
        projectId: "esthetics-auto-cashbook",
        storageBucket: "esthetics-auto-cashbook.appspot.com",
        messagingSenderId: "771238602828",
        appId: "1:771238602828:web:8cc30ab55c99b0f0ce0c20",
        measurementId: "G-KRSK5YMLKK"
      };
      
      // Initialize Firebase if not already done
      if (!firebase.apps.length) {
        this.app = firebase.initializeApp(firebaseConfig);
      } else {
        this.app = firebase.app();
      }
      
      // Initialize services
      this.db = firebase.firestore();
      this.auth = firebase.auth();
      
      // Enable offline persistence
      this.db.enablePersistence().catch((err) => {
        console.warn('Firebase persistence failed:', err);
      });
      
      this.initialized = true;
      console.log('✅ Firebase initialized successfully');
      
      // Set up auth state listener
      this.setupAuthListener();
      
      return true;
    } catch (error) {
      console.error('Firebase initialization failed:', error);
      return false;
    }
  },
  
  // Setup authentication state listener
  setupAuthListener: function() {
    if (!this.auth) return;
    
    this.auth.onAuthStateChanged((user) => {
      if (user) {
        console.log('Firebase user authenticated:', user.uid);
        this.syncUserData();
      } else {
        console.log('Firebase user signed out');
      }
    });
  },
  
  // Sync transactions to Firestore
  syncTransactions: function() {
    if (!this.initialized || !window.appState.transactions) return;
    
    return new Promise((resolve, reject) => {
      try {
        const batch = this.db.batch();
        const transactionsRef = this.db.collection('transactions');
        
        window.appState.transactions.forEach(transaction => {
          const docRef = transactionsRef.doc(transaction.id || CashBookUtils.generateId('txn'));
          batch.set(docRef, {
            ...transaction,
            syncedAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
          }, { merge: true });
        });
        
        batch.commit().then(() => {
          console.log('✅ Transactions synced to Firestore');
          resolve();
        }).catch(reject);
        
      } catch (error) {
        console.error('Transaction sync failed:', error);
        reject(error);
      }
    });
  },
  
  // Sync employees to Firestore
  syncEmployees: function() {
    if (!this.initialized || !window.appState.employees) return;
    
    return new Promise((resolve, reject) => {
      try {
        const batch = this.db.batch();
        const employeesRef = this.db.collection('employees');
        
        window.appState.employees.forEach(employee => {
          const docRef = employeesRef.doc(employee.id || CashBookUtils.generateId('emp'));
          batch.set(docRef, {
            ...employee,
            syncedAt: firebase.firestore.FieldValue.serverTimestamp(),
            updatedAt: firebase.firestore.FieldValue.serverTimestamp()
          }, { merge: true });
        });
        
        batch.commit().then(() => {
          console.log('✅ Employees synced to Firestore');
          resolve();
        }).catch(reject);
        
      } catch (error) {
        console.error('Employee sync failed:', error);
        reject(error);
      }
    });
  },
  
  // Load transactions from Firestore
  loadTransactions: function() {
    if (!this.initialized) return Promise.resolve([]);
    
    return new Promise((resolve, reject) => {
      this.db.collection('transactions')
        .orderBy('date', 'desc')
        .limit(1000)
        .get()
        .then((querySnapshot) => {
          const transactions = [];
          querySnapshot.forEach((doc) => {
            transactions.push({
              id: doc.id,
              ...doc.data()
            });
          });
          console.log(`📥 Loaded ${transactions.length} transactions from Firestore`);
          resolve(transactions);
        })
        .catch((error) => {
          console.error('Failed to load transactions:', error);
          reject(error);
        });
    });
  },
  
  // Load employees from Firestore
  loadEmployees: function() {
    if (!this.initialized) return Promise.resolve([]);
    
    return new Promise((resolve, reject) => {
      this.db.collection('employees')
        .orderBy('name')
        .get()
        .then((querySnapshot) => {
          const employees = [];
          querySnapshot.forEach((doc) => {
            employees.push({
              id: doc.id,
              ...doc.data()
            });
          });
          console.log(`📥 Loaded ${employees.length} employees from Firestore`);
          resolve(employees);
        })
        .catch((error) => {
          console.error('Failed to load employees:', error);
          reject(error);
        });
    });
  },
  
  // Add transaction to Firestore
  addTransaction: function(transaction) {
    if (!this.initialized) return Promise.resolve();
    
    return new Promise((resolve, reject) => {
      const transactionsRef = this.db.collection('transactions');
      const docRef = transactionsRef.doc(transaction.id || CashBookUtils.generateId('txn'));
      
      docRef.set({
        ...transaction,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      }).then(() => {
        console.log('✅ Transaction added to Firestore');
        resolve();
      }).catch((error) => {
        console.error('Failed to add transaction:', error);
        reject(error);
      });
    });
  },
  
  // Update transaction in Firestore
  updateTransaction: function(transactionId, updates) {
    if (!this.initialized) return Promise.resolve();
    
    return new Promise((resolve, reject) => {
      const docRef = this.db.collection('transactions').doc(transactionId);
      
      docRef.update({
        ...updates,
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      }).then(() => {
        console.log('✅ Transaction updated in Firestore');
        resolve();
      }).catch((error) => {
        console.error('Failed to update transaction:', error);
        reject(error);
      });
    });
  },
  
  // Delete transaction from Firestore
  deleteTransaction: function(transactionId) {
    if (!this.initialized) return Promise.resolve();
    
    return new Promise((resolve, reject) => {
      this.db.collection('transactions').doc(transactionId).delete()
        .then(() => {
          console.log('✅ Transaction deleted from Firestore');
          resolve();
        }).catch((error) => {
          console.error('Failed to delete transaction:', error);
          reject(error);
        });
    });
  },
  
  // Add employee to Firestore
  addEmployee: function(employee) {
    if (!this.initialized) return Promise.resolve();
    
    return new Promise((resolve, reject) => {
      const employeesRef = this.db.collection('employees');
      const docRef = employeesRef.doc(employee.id || CashBookUtils.generateId('emp'));
      
      docRef.set({
        ...employee,
        createdAt: firebase.firestore.FieldValue.serverTimestamp(),
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      }).then(() => {
        console.log('✅ Employee added to Firestore');
        resolve();
      }).catch((error) => {
        console.error('Failed to add employee:', error);
        reject(error);
      });
    });
  },
  
  // Update employee in Firestore
  updateEmployee: function(employeeId, updates) {
    if (!this.initialized) return Promise.resolve();
    
    return new Promise((resolve, reject) => {
      const docRef = this.db.collection('employees').doc(employeeId);
      
      docRef.update({
        ...updates,
        updatedAt: firebase.firestore.FieldValue.serverTimestamp()
      }).then(() => {
        console.log('✅ Employee updated in Firestore');
        resolve();
      }).catch((error) => {
        console.error('Failed to update employee:', error);
        reject(error);
      });
    });
  },
  
  // Delete employee from Firestore
  deleteEmployee: function(employeeId) {
    if (!this.initialized) return Promise.resolve();
    
    return new Promise((resolve, reject) => {
      this.db.collection('employees').doc(employeeId).delete()
        .then(() => {
          console.log('✅ Employee deleted from Firestore');
          resolve();
        }).catch((error) => {
          console.error('Failed to delete employee:', error);
          reject(error);
        });
    });
  },
  
  // Setup real-time listeners
  setupRealtimeListeners: function() {
    if (!this.initialized) return;
    
    // Listen to transactions
    this.db.collection('transactions')
      .orderBy('date', 'desc')
      .limit(500)
      .onSnapshot((snapshot) => {
        snapshot.docChanges().forEach((change) => {
          if (change.type === 'added') {
            console.log('Transaction added:', change.doc.data());
          }
          if (change.type === 'modified') {
            console.log('Transaction modified:', change.doc.data());
          }
          if (change.type === 'removed') {
            console.log('Transaction removed:', change.doc.data());
          }
        });
        
        // Update local state if needed
        this.syncLocalTransactions(snapshot);
      });
    
    // Listen to employees
    this.db.collection('employees')
      .onSnapshot((snapshot) => {
        snapshot.docChanges().forEach((change) => {
          if (change.type === 'added') {
            console.log('Employee added:', change.doc.data());
          }
          if (change.type === 'modified') {
            console.log('Employee modified:', change.doc.data());
          }
          if (change.type === 'removed') {
            console.log('Employee removed:', change.doc.data());
          }
        });
        
        // Update local state if needed
        this.syncLocalEmployees(snapshot);
      });
  },
  
  // Sync local transactions with Firestore snapshot
  syncLocalTransactions: function(snapshot) {
    const transactions = [];
    snapshot.forEach((doc) => {
      transactions.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    // Update local state
    window.appState.transactions = transactions;
    
    // Update localStorage
    CashBookUtils.LS.set('transactions', transactions);
    
    // Refresh dashboard if loaded
    if (typeof DashboardModule !== 'undefined' && DashboardModule.loadDashboard) {
      DashboardModule.loadDashboard();
    }
    
    // Refresh transactions view if loaded
    if (typeof TransactionsModule !== 'undefined' && TransactionsModule.loadTransactions) {
      TransactionsModule.loadTransactions();
    }
  },
  
  // Sync local employees with Firestore snapshot
  syncLocalEmployees: function(snapshot) {
    const employees = [];
    snapshot.forEach((doc) => {
      employees.push({
        id: doc.id,
        ...doc.data()
      });
    });
    
    // Update local state
    window.appState.employees = employees;
    
    // Update localStorage
    CashBookUtils.LS.set('employees', employees);
    
    // Refresh employees view if loaded
    if (typeof EmployeesModule !== 'undefined' && EmployeesModule.loadEmployees) {
      EmployeesModule.loadEmployees();
    }
  },
  
  // Sync all data to Firestore
  syncAll: function() {
    if (!this.initialized) {
      console.warn('Firebase not initialized');
      return Promise.resolve();
    }
    
    console.log('🔄 Starting full sync to Firestore...');
    
    return Promise.all([
      this.syncTransactions(),
      this.syncEmployees()
    ]).then(() => {
      console.log('✅ Full sync completed');
      CashBookUtils.showToast('Data synced to cloud successfully', 'success');
    }).catch((error) => {
      console.error('Sync failed:', error);
      CashBookUtils.showToast('Cloud sync failed', 'error');
    });
  },
  
  // Load all data from Firestore
  loadAll: function() {
    if (!this.initialized) {
      console.warn('Firebase not initialized');
      return Promise.resolve();
    }
    
    console.log('📥 Loading all data from Firestore...');
    
    return Promise.all([
      this.loadTransactions(),
      this.loadEmployees()
    ]).then(([transactions, employees]) => {
      // Update app state
      window.appState.transactions = transactions;
      window.appState.employees = employees;
      
      // Update localStorage
      CashBookUtils.LS.set('transactions', transactions);
      CashBookUtils.LS.set('employees', employees);
      
      console.log('✅ All data loaded from Firestore');
      CashBookUtils.showToast('Data loaded from cloud successfully', 'success');
      
      // Refresh all views
      this.refreshAllViews();
      
      return { transactions, employees };
    }).catch((error) => {
      console.error('Load failed:', error);
      CashBookUtils.showToast('Failed to load data from cloud', 'error');
    });
  },
  
  // Refresh all application views
  refreshAllViews: function() {
    // Refresh dashboard
    if (typeof DashboardModule !== 'undefined' && DashboardModule.loadDashboard) {
      DashboardModule.loadDashboard();
    }
    
    // Refresh transactions
    if (typeof TransactionsModule !== 'undefined' && TransactionsModule.loadTransactions) {
      TransactionsModule.loadTransactions();
    }
    
    // Refresh employees
    if (typeof EmployeesModule !== 'undefined' && EmployeesModule.loadEmployees) {
      EmployeesModule.loadEmployees();
    }
  },
  
  // Check connection status
  isOnline: function() {
    return navigator.onLine && this.initialized;
  },
  
  // Get sync status
  getSyncStatus: function() {
    return {
      initialized: this.initialized,
      online: navigator.onLine,
      hasTransactions: window.appState.transactions && window.appState.transactions.length > 0,
      hasEmployees: window.appState.employees && window.appState.employees.length > 0
    };
  },
  
  // Save backup to Firebase
  saveBackupToFirebase: function(backupData) {
    if (!this.initialized) {
      console.warn('Firebase not initialized - backup saved locally only');
      return Promise.resolve();
    }
    
    return new Promise((resolve, reject) => {
      try {
        const backupsRef = this.db.collection('backups');
        const backupId = `backup_${Date.now()}`;
        
        const firebaseBackupData = {
          ...backupData,
          backupId: backupId,
          createdAt: firebase.firestore.FieldValue.serverTimestamp(),
          deviceInfo: {
            userAgent: navigator.userAgent,
            platform: navigator.platform,
            language: navigator.language
          }
        };
        
        backupsRef.doc(backupId).set(firebaseBackupData)
          .then(() => {
            console.log('✅ Backup saved to Firebase');
            
            // Clean old backups (keep only last 10)
            this.cleanOldFirebaseBackups();
            
            resolve();
          })
          .catch((error) => {
            console.error('Failed to save backup to Firebase:', error);
            reject(error);
          });
          
      } catch (error) {
        console.error('Firebase backup error:', error);
        reject(error);
      }
    });
  },
  
  // Clean old Firebase backups
  cleanOldFirebaseBackups: function() {
    if (!this.initialized) return;
    
    this.db.collection('backups')
      .orderBy('createdAt', 'desc')
      .limit(20) // Get more than we need
      .get()
      .then((querySnapshot) => {
        const docs = [];
        querySnapshot.forEach((doc) => {
          docs.push(doc);
        });
        
        // If we have more than 10 backups, delete the oldest ones
        if (docs.length > 10) {
          const toDelete = docs.slice(10); // Keep first 10, delete rest
          
          const batch = this.db.batch();
          toDelete.forEach((doc) => {
            batch.delete(doc.ref);
          });
          
          batch.commit().then(() => {
            console.log(`🗑️ Cleaned ${toDelete.length} old Firebase backups`);
          }).catch((error) => {
            console.error('Failed to clean old backups:', error);
          });
        }
      })
      .catch((error) => {
        console.error('Failed to query backups for cleanup:', error);
      });
  },
  
  // Load latest backup from Firebase
  loadLatestBackupFromFirebase: function() {
    if (!this.initialized) {
      console.warn('Firebase not initialized');
      return Promise.reject('Firebase not initialized');
    }
    
    return new Promise((resolve, reject) => {
      this.db.collection('backups')
        .orderBy('createdAt', 'desc')
        .limit(1)
        .get()
        .then((querySnapshot) => {
          if (querySnapshot.empty) {
            resolve(null);
            return;
          }
          
          const latestBackup = querySnapshot.docs[0].data();
          console.log('📥 Latest backup loaded from Firebase');
          resolve(latestBackup);
        })
        .catch((error) => {
          console.error('Failed to load backup from Firebase:', error);
          reject(error);
        });
    });
  },
  
  // List all Firebase backups
  listFirebaseBackups: function() {
    if (!this.initialized) {
      console.warn('Firebase not initialized');
      return Promise.resolve([]);
    }
    
    return new Promise((resolve, reject) => {
      this.db.collection('backups')
        .orderBy('createdAt', 'desc')
        .limit(10)
        .get()
        .then((querySnapshot) => {
          const backups = [];
          querySnapshot.forEach((doc) => {
            const data = doc.data();
            backups.push({
              id: doc.id,
              timestamp: data.timestamp,
              createdAt: data.createdAt,
              transactionCount: data.transactions ? data.transactions.length : 0,
              employeeCount: data.employees ? data.employees.length : 0,
              categoryCount: data.categories ? data.categories.length : 0,
              accountCount: data.accounts ? data.accounts.length : 0
            });
          });
          
          console.log(`📋 Found ${backups.length} Firebase backups`);
          resolve(backups);
        })
        .catch((error) => {
          console.error('Failed to list Firebase backups:', error);
          reject(error);
        });
    });
  }
};

// Global functions for backwards compatibility
function syncToFirestore() {
  return FirebaseModule.syncAll();
}

function loadFromFirestore() {
  return FirebaseModule.loadAll();
}

function initFirebase() {
  return FirebaseModule.init();
}

// Auto-initialize Firebase when script loads
document.addEventListener('DOMContentLoaded', function() {
  // Small delay to ensure other modules are loaded
  setTimeout(() => {
    FirebaseModule.init();
  }, 1000);
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
  module.exports = FirebaseModule;
}