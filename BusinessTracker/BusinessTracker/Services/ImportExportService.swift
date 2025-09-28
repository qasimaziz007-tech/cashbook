import Foundation
import CoreData
import UniformTypeIdentifiers

public class ImportExportService: ObservableObject {
    private let persistenceController: PersistenceController
    private let businessService: BusinessService
    private let transactionService: TransactionService
    private let accountService: AccountService
    
    public init(persistenceController: PersistenceController = .shared, 
                businessService: BusinessService,
                transactionService: TransactionService,
                accountService: AccountService) {
        self.persistenceController = persistenceController
        self.businessService = businessService
        self.transactionService = transactionService
        self.accountService = accountService
    }
    
    // MARK: - JSON Backup/Restore
    
    public func createBackup() -> Data? {
        guard let activeBusiness = businessService.activeBusiness else {
            print("No active business for backup")
            return nil
        }
        
        let backup = BusinessBackup(
            business: BackupBusiness(from: activeBusiness),
            accounts: activeBusiness.accounts?.compactMap { BackupAccount(from: $0 as! Account) } ?? [],
            categories: activeBusiness.categories?.compactMap { BackupCategory(from: $0 as! Category) } ?? [],
            paymentModes: activeBusiness.paymentModes?.compactMap { BackupPaymentMode(from: $0 as! PaymentMode) } ?? [],
            transactions: activeBusiness.transactions?.compactMap { BackupTransaction(from: $0 as! Transaction) } ?? [],
            fundTransfers: getFundTransfersForBusiness(activeBusiness),
            activityLogs: activeBusiness.activityLogs?.compactMap { BackupActivityLog(from: $0 as! ActivityLog) } ?? [],
            exportDate: Date()
        )
        
        do {
            return try JSONEncoder().encode(backup)
        } catch {
            print("Error creating backup: \(error)")
            return nil
        }
    }
    
    public func restoreFromBackup(_ data: Data) -> Bool {
        do {
            let backup = try JSONDecoder().decode(BusinessBackup.self, from: data)
            
            let context = persistenceController.container.viewContext
            
            // Create or update business
            let business = Business(context: context)
            business.id = backup.business.id
            business.name = backup.business.name
            business.address = backup.business.address
            business.currency = backup.business.currency
            business.isActive = true // Make restored business active
            business.createdAt = backup.business.createdAt
            business.updatedAt = Date() // Update to current time
            
            // Deactivate other businesses
            businessService.businesses.forEach { $0.isActive = false }
            
            // Create accounts
            for backupAccount in backup.accounts {
                let account = Account(context: context)
                account.id = backupAccount.id
                account.name = backupAccount.name
                account.currency = backupAccount.currency
                account.openingBalance = NSDecimalNumber(decimal: backupAccount.openingBalance)
                account.currentBalance = NSDecimalNumber(decimal: backupAccount.currentBalance)
                account.createdAt = backupAccount.createdAt
                account.updatedAt = backupAccount.updatedAt
                account.business = business
            }
            
            // Create categories
            for backupCategory in backup.categories {
                let category = Category(context: context)
                category.id = backupCategory.id
                category.name = backupCategory.name
                category.color = backupCategory.color
                category.createdAt = backupCategory.createdAt
                category.business = business
            }
            
            // Create payment modes
            for backupPaymentMode in backup.paymentModes {
                let paymentMode = PaymentMode(context: context)
                paymentMode.id = backupPaymentMode.id
                paymentMode.name = backupPaymentMode.name
                paymentMode.createdAt = backupPaymentMode.createdAt
                paymentMode.business = business
            }
            
            try context.save()
            
            // Reload data
            businessService.loadBusinesses()
            businessService.setActiveBusiness(business)
            
            logActivity(action: "Data Restored", details: "Business data restored from backup")
            
            return true
        } catch {
            print("Error restoring backup: \(error)")
            return false
        }
    }
    
    // MARK: - CSV Export
    
    public func exportTransactionsToCSV(dateRange: DateInterval? = nil) -> String? {
        let transactions = transactionService.getTransactions(for: dateRange)
        
        var csvContent = "Date,Category,Account,Amount,Type,Payment Mode,Notes\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        for transaction in transactions {
            let date = dateFormatter.string(from: transaction.date ?? Date())
            let category = transaction.category?.name ?? ""
            let account = transaction.account?.name ?? ""
            let amount = transaction.amount?.decimalValue ?? 0
            let type = transaction.type ?? ""
            let paymentMode = transaction.paymentMode?.name ?? ""
            let notes = (transaction.notes ?? "").replacingOccurrences(of: "\"", with: "\"\"")
            
            csvContent += "\"\(date)\",\"\(category)\",\"\(account)\",\(amount),\"\(type)\",\"\(paymentMode)\",\"\(notes)\"\n"
        }
        
        return csvContent
    }
    
    // MARK: - CSV Import
    
    public func importTransactionsFromCSV(_ csvContent: String) -> ImportResult {
        let lines = csvContent.components(separatedBy: .newlines)
        guard lines.count > 1 else {
            return ImportResult(success: false, importedCount: 0, skippedCount: 0, errors: ["No data found in CSV"])
        }
        
        let headers = parseCSVLine(lines[0])
        guard validateCSVHeaders(headers) else {
            return ImportResult(success: false, importedCount: 0, skippedCount: 0, errors: ["Invalid CSV headers. Expected: Date,Category,Account,Amount,Type,Payment Mode,Notes"])
        }
        
        var importedCount = 0
        var skippedCount = 0
        var errors: [String] = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        for (index, line) in lines.dropFirst().enumerated() {
            guard !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { continue }
            
            let values = parseCSVLine(line)
            guard values.count >= 5 else {
                skippedCount += 1
                errors.append("Row \(index + 2): Insufficient data")
                continue
            }
            
            // Parse and validate data
            guard let date = dateFormatter.date(from: values[0]) else {
                skippedCount += 1
                errors.append("Row \(index + 2): Invalid date format")
                continue
            }
            
            let categoryName = values[1]
            let accountName = values[2]
            
            guard let amount = Decimal(string: values[3]), amount > 0 else {
                skippedCount += 1
                errors.append("Row \(index + 2): Invalid amount")
                continue
            }
            
            guard let transactionType = TransactionType(rawValue: values[4].lowercased()) else {
                skippedCount += 1
                errors.append("Row \(index + 2): Invalid transaction type")
                continue
            }
            
            let paymentModeName = values.count > 5 ? values[5] : ""
            let notes = values.count > 6 ? values[6] : ""
            
            // Find or create category, account, and payment mode
            let category = findOrCreateCategory(name: categoryName)
            let account = findOrCreateAccount(name: accountName)
            let paymentMode = !paymentModeName.isEmpty ? findOrCreatePaymentMode(name: paymentModeName) : nil
            
            // Create transaction
            if transactionService.createTransaction(
                amount: amount,
                type: transactionType,
                account: account,
                category: category,
                paymentMode: paymentMode,
                notes: notes.isEmpty ? nil : notes,
                date: date
            ) != nil {
                importedCount += 1
            } else {
                skippedCount += 1
                errors.append("Row \(index + 2): Failed to create transaction")
            }
        }
        
        return ImportResult(
            success: importedCount > 0,
            importedCount: importedCount,
            skippedCount: skippedCount,
            errors: errors
        )
    }
    
    // MARK: - Helper Methods
    
    private func getFundTransfersForBusiness(_ business: Business) -> [BackupFundTransfer] {
        let request: NSFetchRequest<FundTransfer> = FundTransfer.fetchRequest()
        request.predicate = NSPredicate(format: "fromAccount.business == %@ OR toAccount.business == %@", business, business)
        
        do {
            let transfers = try persistenceController.container.viewContext.fetch(request)
            return transfers.compactMap { BackupFundTransfer(from: $0) }
        } catch {
            print("Error fetching fund transfers: \(error)")
            return []
        }
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var result: [String] = []
        var currentField = ""
        var insideQuotes = false
        var i = line.startIndex
        
        while i < line.endIndex {
            let char = line[i]
            
            if char == "\"" {
                if insideQuotes && i < line.index(before: line.endIndex) && line[line.index(after: i)] == "\"" {
                    currentField += "\""
                    i = line.index(after: i)
                } else {
                    insideQuotes.toggle()
                }
            } else if char == "," && !insideQuotes {
                result.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
            
            i = line.index(after: i)
        }
        
        result.append(currentField)
        return result
    }
    
    private func validateCSVHeaders(_ headers: [String]) -> Bool {
        let expectedHeaders = ["Date", "Category", "Account", "Amount", "Type"]
        let normalizedHeaders = headers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        
        for (index, expected) in expectedHeaders.enumerated() {
            if index >= normalizedHeaders.count || normalizedHeaders[index] != expected {
                return false
            }
        }
        
        return true
    }
    
    private func findOrCreateCategory(name: String) -> Category {
        guard let activeBusiness = businessService.activeBusiness else {
            fatalError("No active business")
        }
        
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND business == %@", name, activeBusiness)
        
        if let existingCategory = try? context.fetch(request).first {
            return existingCategory
        }
        
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.createdAt = Date()
        category.business = activeBusiness
        
        try? context.save()
        return category
    }
    
    private func findOrCreateAccount(name: String) -> Account {
        guard let activeBusiness = businessService.activeBusiness else {
            fatalError("No active business")
        }
        
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND business == %@", name, activeBusiness)
        
        if let existingAccount = try? context.fetch(request).first {
            return existingAccount
        }
        
        let account = Account(context: context)
        account.id = UUID()
        account.name = name
        account.currency = activeBusiness.currency ?? "USD"
        account.openingBalance = NSDecimalNumber(decimal: 0)
        account.currentBalance = NSDecimalNumber(decimal: 0)
        account.createdAt = Date()
        account.updatedAt = Date()
        account.business = activeBusiness
        
        try? context.save()
        return account
    }
    
    private func findOrCreatePaymentMode(name: String) -> PaymentMode {
        guard let activeBusiness = businessService.activeBusiness else {
            fatalError("No active business")
        }
        
        let context = persistenceController.container.viewContext
        let request: NSFetchRequest<PaymentMode> = PaymentMode.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@ AND business == %@", name, activeBusiness)
        
        if let existingPaymentMode = try? context.fetch(request).first {
            return existingPaymentMode
        }
        
        let paymentMode = PaymentMode(context: context)
        paymentMode.id = UUID()
        paymentMode.name = name
        paymentMode.createdAt = Date()
        paymentMode.business = activeBusiness
        
        try? context.save()
        return paymentMode
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

// MARK: - Supporting Types

public struct ImportResult {
    public let success: Bool
    public let importedCount: Int
    public let skippedCount: Int
    public let errors: [String]
}

// Backup data structures
public struct BusinessBackup: Codable {
    let business: BackupBusiness
    let accounts: [BackupAccount]
    let categories: [BackupCategory]
    let paymentModes: [BackupPaymentMode]
    let transactions: [BackupTransaction]
    let fundTransfers: [BackupFundTransfer]
    let activityLogs: [BackupActivityLog]
    let exportDate: Date
}

public struct BackupBusiness: Codable {
    let id: UUID
    let name: String
    let address: String?
    let currency: String
    let createdAt: Date
    
    init(from business: Business) {
        self.id = business.id ?? UUID()
        self.name = business.name ?? ""
        self.address = business.address
        self.currency = business.currency ?? "USD"
        self.createdAt = business.createdAt ?? Date()
    }
}

public struct BackupAccount: Codable {
    let id: UUID
    let name: String
    let currency: String
    let openingBalance: Decimal
    let currentBalance: Decimal
    let createdAt: Date
    let updatedAt: Date
    
    init(from account: Account) {
        self.id = account.id ?? UUID()
        self.name = account.name ?? ""
        self.currency = account.currency ?? "USD"
        self.openingBalance = account.openingBalance?.decimalValue ?? 0
        self.currentBalance = account.currentBalance?.decimalValue ?? 0
        self.createdAt = account.createdAt ?? Date()
        self.updatedAt = account.updatedAt ?? Date()
    }
}

public struct BackupCategory: Codable {
    let id: UUID
    let name: String
    let color: String?
    let createdAt: Date
    
    init(from category: Category) {
        self.id = category.id ?? UUID()
        self.name = category.name ?? ""
        self.color = category.color
        self.createdAt = category.createdAt ?? Date()
    }
}

public struct BackupPaymentMode: Codable {
    let id: UUID
    let name: String
    let createdAt: Date
    
    init(from paymentMode: PaymentMode) {
        self.id = paymentMode.id ?? UUID()
        self.name = paymentMode.name ?? ""
        self.createdAt = paymentMode.createdAt ?? Date()
    }
}

public struct BackupTransaction: Codable {
    let id: UUID
    let amount: Decimal
    let type: String
    let notes: String?
    let date: Date
    let createdAt: Date
    let accountId: UUID
    let categoryId: UUID
    let paymentModeId: UUID?
    
    init(from transaction: Transaction) {
        self.id = transaction.id ?? UUID()
        self.amount = transaction.amount?.decimalValue ?? 0
        self.type = transaction.type ?? ""
        self.notes = transaction.notes
        self.date = transaction.date ?? Date()
        self.createdAt = transaction.createdAt ?? Date()
        self.accountId = transaction.account?.id ?? UUID()
        self.categoryId = transaction.category?.id ?? UUID()
        self.paymentModeId = transaction.paymentMode?.id
    }
}

public struct BackupFundTransfer: Codable {
    let id: UUID
    let amount: Decimal
    let notes: String?
    let date: Date
    let createdAt: Date
    let fromAccountId: UUID
    let toAccountId: UUID
    
    init(from transfer: FundTransfer) {
        self.id = transfer.id ?? UUID()
        self.amount = transfer.amount?.decimalValue ?? 0
        self.notes = transfer.notes
        self.date = transfer.date ?? Date()
        self.createdAt = transfer.createdAt ?? Date()
        self.fromAccountId = transfer.fromAccount?.id ?? UUID()
        self.toAccountId = transfer.toAccount?.id ?? UUID()
    }
}

public struct BackupActivityLog: Codable {
    let id: UUID
    let action: String
    let details: String?
    let timestamp: Date
    
    init(from log: ActivityLog) {
        self.id = log.id ?? UUID()
        self.action = log.action ?? ""
        self.details = log.details
        self.timestamp = log.timestamp ?? Date()
    }
}