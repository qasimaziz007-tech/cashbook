import SwiftUI

public struct TransactionsView: View {
    @ObservedObject var transactionService: TransactionService
    @ObservedObject var accountService: AccountService
    @ObservedObject var businessService: BusinessService
    
    @State private var showingAddTransaction = false
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(transactionService.transactions, id: \.id) { transaction in
                    TransactionRowView(transaction: transaction)
                }
                .onDelete(perform: deleteTransactions)
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddTransaction = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddTransaction) {
                AddTransactionView(
                    transactionService: transactionService,
                    accountService: accountService,
                    businessService: businessService
                )
            }
            .refreshable {
                transactionService.loadTransactions()
            }
        }
    }
    
    private func deleteTransactions(offsets: IndexSet) {
        for index in offsets {
            let transaction = transactionService.transactions[index]
            transactionService.deleteTransaction(transaction)
        }
    }
}

struct AddTransactionView: View {
    @ObservedObject var transactionService: TransactionService
    @ObservedObject var accountService: AccountService
    @ObservedObject var businessService: BusinessService
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var amount = ""
    @State private var selectedType = TransactionType.expense
    @State private var selectedAccount: Account?
    @State private var selectedCategory: Category?
    @State private var selectedPaymentMode: PaymentMode?
    @State private var notes = ""
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section("Transaction Details") {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    Picker("Type", selection: $selectedType) {
                        ForEach(TransactionType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Picker("Account", selection: $selectedAccount) {
                        Text("Select Account").tag(Account?.none)
                        ForEach(accountService.accounts, id: \.id) { account in
                            Text(account.name ?? "Unknown").tag(account as Account?)
                        }
                    }
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Additional Information") {
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTransaction()
                    }
                    .disabled(!isValidTransaction)
                }
            }
        }
    }
    
    private var isValidTransaction: Bool {
        guard let _ = Decimal(string: amount),
              let _ = selectedAccount else {
            return false
        }
        return true
    }
    
    private func saveTransaction() {
        guard let amountDecimal = Decimal(string: amount),
              let account = selectedAccount else {
            return
        }
        
        // For now, create a default category if none selected
        let category = selectedCategory ?? createDefaultCategory()
        
        transactionService.createTransaction(
            amount: amountDecimal,
            type: selectedType,
            account: account,
            category: category,
            paymentMode: selectedPaymentMode,
            notes: notes.isEmpty ? nil : notes,
            date: date
        )
        
        dismiss()
    }
    
    private func createDefaultCategory() -> Category {
        // This is a temporary solution - in a complete implementation,
        // we would have a proper category selection interface
        let context = PersistenceController.shared.container.viewContext
        let category = Category(context: context)
        category.id = UUID()
        category.name = "General"
        category.createdAt = Date()
        category.business = businessService.activeBusiness
        
        try? context.save()
        return category
    }
}

#Preview {
    TransactionsView(
        transactionService: TransactionService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview)),
        accountService: AccountService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview)),
        businessService: BusinessService(persistenceController: .preview)
    )
}