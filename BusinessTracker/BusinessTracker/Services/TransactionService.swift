import CoreData
import Foundation

public class TransactionService: ObservableObject {
    private let persistenceController: PersistenceController
    private let businessService: BusinessService
    
    @Published public var transactions: [Transaction] = []
    
    public init(persistenceController: PersistenceController = .shared, businessService: BusinessService) {
        self.persistenceController = persistenceController
        self.businessService = businessService
        loadTransactions()
    }
    
    public func loadTransactions() {
        guard let activeBusiness = businessService.activeBusiness else {
            transactions = []
            return
        }
        
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "business == %@", activeBusiness)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Transaction.date, ascending: false)]
        
        do {
            transactions = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error loading transactions: \(error)")
        }
    }
    
    public func createTransaction(
        amount: Decimal,
        type: TransactionType,
        account: Account,
        category: Category,
        paymentMode: PaymentMode?,
        notes: String?,
        date: Date = Date()
    ) -> Transaction? {
        guard let activeBusiness = businessService.activeBusiness else {
            print("No active business")
            return nil
        }
        
        let context = persistenceController.container.viewContext
        let transaction = Transaction(context: context)
        
        transaction.id = UUID()
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.type = type.rawValue
        transaction.account = account
        transaction.category = category
        transaction.paymentMode = paymentMode
        transaction.notes = notes
        transaction.date = date
        transaction.createdAt = Date()
        transaction.updatedAt = Date()
        transaction.business = activeBusiness
        
        // Update account balance
        updateAccountBalance(account: account, amount: amount, type: type, isAdding: true)
        
        do {
            try context.save()
            loadTransactions()
            logActivity(action: "Transaction Created", details: "\(type.displayName) of \(amount) added to \(account.name ?? "")")
            return transaction
        } catch {
            print("Error creating transaction: \(error)")
            context.rollback()
            return nil
        }
    }
    
    public func updateTransaction(
        _ transaction: Transaction,
        amount: Decimal,
        type: TransactionType,
        account: Account,
        category: Category,
        paymentMode: PaymentMode?,
        notes: String?,
        date: Date
    ) {
        let context = persistenceController.container.viewContext
        
        // Revert old transaction's effect on account balance
        if let oldAccount = transaction.account,
           let oldAmount = transaction.amount?.decimalValue,
           let oldType = TransactionType(rawValue: transaction.type ?? "") {
            updateAccountBalance(account: oldAccount, amount: oldAmount, type: oldType, isAdding: false)
        }
        
        // Update transaction
        transaction.amount = NSDecimalNumber(decimal: amount)
        transaction.type = type.rawValue
        transaction.account = account
        transaction.category = category
        transaction.paymentMode = paymentMode
        transaction.notes = notes
        transaction.date = date
        transaction.updatedAt = Date()
        
        // Apply new transaction's effect on account balance
        updateAccountBalance(account: account, amount: amount, type: type, isAdding: true)
        
        do {
            try context.save()
            loadTransactions()
            logActivity(action: "Transaction Updated", details: "\(type.displayName) updated in \(account.name ?? "")")
        } catch {
            print("Error updating transaction: \(error)")
        }
    }
    
    public func deleteTransaction(_ transaction: Transaction) {
        let context = persistenceController.container.viewContext
        
        // Revert transaction's effect on account balance
        if let account = transaction.account,
           let amount = transaction.amount?.decimalValue,
           let type = TransactionType(rawValue: transaction.type ?? "") {
            updateAccountBalance(account: account, amount: amount, type: type, isAdding: false)
        }
        
        context.delete(transaction)
        
        do {
            try context.save()
            loadTransactions()
            logActivity(action: "Transaction Deleted", details: "Transaction removed")
        } catch {
            print("Error deleting transaction: \(error)")
        }
    }
    
    public func getTransactions(for dateRange: DateInterval? = nil, account: Account? = nil, category: Category? = nil) -> [Transaction] {
        var filteredTransactions = transactions
        
        if let dateRange = dateRange {
            filteredTransactions = filteredTransactions.filter { transaction in
                dateRange.contains(transaction.date ?? Date())
            }
        }
        
        if let account = account {
            filteredTransactions = filteredTransactions.filter { $0.account == account }
        }
        
        if let category = category {
            filteredTransactions = filteredTransactions.filter { $0.category == category }
        }
        
        return filteredTransactions
    }
    
    public func getTotalIncome(for dateRange: DateInterval? = nil) -> Decimal {
        let incomeTransactions = getTransactions(for: dateRange).filter { $0.type == TransactionType.income.rawValue }
        return incomeTransactions.reduce(0) { total, transaction in
            total + (transaction.amount?.decimalValue ?? 0)
        }
    }
    
    public func getTotalExpense(for dateRange: DateInterval? = nil) -> Decimal {
        let expenseTransactions = getTransactions(for: dateRange).filter { $0.type == TransactionType.expense.rawValue }
        return expenseTransactions.reduce(0) { total, transaction in
            total + (transaction.amount?.decimalValue ?? 0)
        }
    }
    
    public func getNetIncome(for dateRange: DateInterval? = nil) -> Decimal {
        return getTotalIncome(for: dateRange) - getTotalExpense(for: dateRange)
    }
    
    private func updateAccountBalance(account: Account, amount: Decimal, type: TransactionType, isAdding: Bool) {
        let currentBalance = account.currentBalance?.decimalValue ?? 0
        let multiplier: Decimal = isAdding ? 1 : -1
        
        switch type {
        case .income:
            account.currentBalance = NSDecimalNumber(decimal: currentBalance + (amount * multiplier))
        case .expense:
            account.currentBalance = NSDecimalNumber(decimal: currentBalance - (amount * multiplier))
        }
        
        account.updatedAt = Date()
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