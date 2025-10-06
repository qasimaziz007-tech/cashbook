import CoreData
import Foundation

public class AccountService: ObservableObject {
    private let persistenceController: PersistenceController
    private let businessService: BusinessService
    
    @Published public var accounts: [Account] = []
    
    public init(persistenceController: PersistenceController = .shared, businessService: BusinessService) {
        self.persistenceController = persistenceController
        self.businessService = businessService
        loadAccounts()
    }
    
    public func loadAccounts() {
        guard let activeBusiness = businessService.activeBusiness else {
            accounts = []
            return
        }
        
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "business == %@", activeBusiness)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
        
        do {
            accounts = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error loading accounts: \(error)")
        }
    }
    
    public func createAccount(name: String, currency: String, openingBalance: Decimal) -> Account? {
        guard let activeBusiness = businessService.activeBusiness else {
            print("No active business")
            return nil
        }
        
        let context = persistenceController.container.viewContext
        let account = Account(context: context)
        
        account.id = UUID()
        account.name = name
        account.currency = currency
        account.openingBalance = NSDecimalNumber(decimal: openingBalance)
        account.currentBalance = NSDecimalNumber(decimal: openingBalance)
        account.createdAt = Date()
        account.updatedAt = Date()
        account.business = activeBusiness
        
        do {
            try context.save()
            loadAccounts()
            logActivity(action: "Account Created", details: "Account '\(name)' created with opening balance \(openingBalance)")
            return account
        } catch {
            print("Error creating account: \(error)")
            context.rollback()
            return nil
        }
    }
    
    public func updateAccount(_ account: Account, name: String, currency: String, openingBalance: Decimal) {
        let context = persistenceController.container.viewContext
        
        // Calculate the difference in opening balance
        let oldOpeningBalance = account.openingBalance?.decimalValue ?? 0
        let balanceDifference = openingBalance - oldOpeningBalance
        
        // Update current balance by the difference
        let currentBalance = account.currentBalance?.decimalValue ?? 0
        account.currentBalance = NSDecimalNumber(decimal: currentBalance + balanceDifference)
        
        account.name = name
        account.currency = currency
        account.openingBalance = NSDecimalNumber(decimal: openingBalance)
        account.updatedAt = Date()
        
        do {
            try context.save()
            loadAccounts()
            logActivity(action: "Account Updated", details: "Account '\(name)' updated")
        } catch {
            print("Error updating account: \(error)")
        }
    }
    
    public func deleteAccount(_ account: Account) {
        let context = persistenceController.container.viewContext
        
        // Check if account has transactions
        let transactionCount = account.transactions?.count ?? 0
        if transactionCount > 0 {
            print("Cannot delete account with existing transactions")
            return
        }
        
        context.delete(account)
        
        do {
            try context.save()
            loadAccounts()
            logActivity(action: "Account Deleted", details: "Account '\(account.name ?? "")' deleted")
        } catch {
            print("Error deleting account: \(error)")
        }
    }
    
    public func transferFunds(from fromAccount: Account, to toAccount: Account, amount: Decimal, notes: String? = nil, date: Date = Date()) -> Bool {
        guard fromAccount != toAccount else {
            print("Cannot transfer to the same account")
            return false
        }
        
        let fromBalance = fromAccount.currentBalance?.decimalValue ?? 0
        guard fromBalance >= amount else {
            print("Insufficient balance")
            return false
        }
        
        let context = persistenceController.container.viewContext
        
        // Create fund transfer record
        let transfer = FundTransfer(context: context)
        transfer.id = UUID()
        transfer.amount = NSDecimalNumber(decimal: amount)
        transfer.notes = notes
        transfer.date = date
        transfer.createdAt = Date()
        transfer.fromAccount = fromAccount
        transfer.toAccount = toAccount
        
        // Update account balances
        fromAccount.currentBalance = NSDecimalNumber(decimal: fromBalance - amount)
        fromAccount.updatedAt = Date()
        
        let toBalance = toAccount.currentBalance?.decimalValue ?? 0
        toAccount.currentBalance = NSDecimalNumber(decimal: toBalance + amount)
        toAccount.updatedAt = Date()
        
        do {
            try context.save()
            loadAccounts()
            logActivity(action: "Fund Transfer", details: "Transferred \(amount) from \(fromAccount.name ?? "") to \(toAccount.name ?? "")")
            return true
        } catch {
            print("Error transferring funds: \(error)")
            context.rollback()
            return false
        }
    }
    
    public func getTotalBalance() -> Decimal {
        return accounts.reduce(0) { total, account in
            total + (account.currentBalance?.decimalValue ?? 0)
        }
    }
    
    public func getAccountBalance(_ account: Account, in currency: String) -> Decimal {
        // For now, return the balance as-is
        // In a full implementation, you would convert currencies here
        return account.currentBalance?.decimalValue ?? 0
    }
    
    public func getFundTransfers(for account: Account? = nil) -> [FundTransfer] {
        let request: NSFetchRequest<FundTransfer> = FundTransfer.fetchRequest()
        
        if let account = account {
            request.predicate = NSPredicate(format: "fromAccount == %@ OR toAccount == %@", account, account)
        }
        
        request.sortDescriptors = [NSSortDescriptor(keyPath: \FundTransfer.date, ascending: false)]
        
        do {
            return try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error loading fund transfers: \(error)")
            return []
        }
    }
    
    private func logActivity(action: String, details: String) {
        guard let activeBusiness = businessService.activeBusiness else { return }
        
        let context = persistenceController.container.viewContext
        let log = ActivityLog(context: context)
        
        log.id = UUID()
        log.action = action
        log.details = details
        log.timestamp = Date()
        log.business = activeBusiness
        
        try? context.save()
    }
}