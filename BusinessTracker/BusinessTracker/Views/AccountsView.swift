import SwiftUI

public struct AccountsView: View {
    @ObservedObject var accountService: AccountService
    @ObservedObject var businessService: BusinessService
    
    @State private var showingAddAccount = false
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(accountService.accounts, id: \.id) { account in
                    AccountRowView(account: account)
                }
                .onDelete(perform: deleteAccounts)
            }
            .navigationTitle("Accounts")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddAccount = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddAccount) {
                AddAccountView(accountService: accountService, businessService: businessService)
            }
            .refreshable {
                accountService.loadAccounts()
            }
        }
    }
    
    private func deleteAccounts(offsets: IndexSet) {
        for index in offsets {
            let account = accountService.accounts[index]
            accountService.deleteAccount(account)
        }
    }
}

struct AddAccountView: View {
    @ObservedObject var accountService: AccountService
    @ObservedObject var businessService: BusinessService
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var selectedCurrency = Currency.supportedCurrencies[0]
    @State private var openingBalance = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Account Information") {
                    TextField("Account Name", text: $name)
                    
                    Picker("Currency", selection: $selectedCurrency) {
                        ForEach(Currency.supportedCurrencies, id: \.code) { currency in
                            HStack {
                                Text(currency.symbol)
                                Text(currency.name)
                                Text("(\(currency.code))")
                                    .foregroundColor(.secondary)
                            }
                            .tag(currency)
                        }
                    }
                    
                    TextField("Opening Balance", text: $openingBalance)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Add Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveAccount()
                    }
                    .disabled(!isValidAccount)
                }
            }
        }
    }
    
    private var isValidAccount: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Decimal(string: openingBalance) != nil
    }
    
    private func saveAccount() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let balance = Decimal(string: openingBalance) else { return }
        
        accountService.createAccount(
            name: trimmedName,
            currency: selectedCurrency.code,
            openingBalance: balance
        )
        
        dismiss()
    }
}

#Preview {
    AccountsView(
        accountService: AccountService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview)),
        businessService: BusinessService(persistenceController: .preview)
    )
}