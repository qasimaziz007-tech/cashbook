import SwiftUI

public struct TransferView: View {
    @ObservedObject var accountService: AccountService
    
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    @State private var amount = ""
    @State private var notes = ""
    @State private var date = Date()
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Transfer Details") {
                    Picker("From Account", selection: $fromAccount) {
                        Text("Select Account").tag(Account?.none)
                        ForEach(accountService.accounts, id: \.id) { account in
                            Text("\(account.name ?? "Unknown") - \(formatBalance(account))").tag(account as Account?)
                        }
                    }
                    
                    Picker("To Account", selection: $toAccount) {
                        Text("Select Account").tag(Account?.none)
                        ForEach(accountService.accounts, id: \.id) { account in
                            if account != fromAccount {
                                Text("\(account.name ?? "Unknown") - \(formatBalance(account))").tag(account as Account?)
                            }
                        }
                    }
                    
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Additional Information") {
                    TextField("Notes (Optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Transfer Funds") {
                        performTransfer()
                    }
                    .frame(maxWidth: .infinity)
                    .disabled(!isValidTransfer)
                }
            }
            .navigationTitle("Fund Transfer")
            .alert("Transfer Result", isPresented: $showingAlert) {
                Button("OK") {
                    if alertMessage.contains("successful") {
                        clearForm()
                    }
                }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private var isValidTransfer: Bool {
        guard let fromAcc = fromAccount,
              let toAcc = toAccount,
              let transferAmount = Decimal(string: amount),
              fromAcc != toAcc,
              transferAmount > 0 else {
            return false
        }
        
        let fromBalance = fromAcc.currentBalance?.decimalValue ?? 0
        return fromBalance >= transferAmount
    }
    
    private func performTransfer() {
        guard let fromAcc = fromAccount,
              let toAcc = toAccount,
              let transferAmount = Decimal(string: amount) else {
            return
        }
        
        let success = accountService.transferFunds(
            from: fromAcc,
            to: toAcc,
            amount: transferAmount,
            notes: notes.isEmpty ? nil : notes,
            date: date
        )
        
        if success {
            alertMessage = "Transfer of \(formatCurrency(transferAmount)) from \(fromAcc.name ?? "Unknown") to \(toAcc.name ?? "Unknown") was successful!"
        } else {
            alertMessage = "Transfer failed. Please check the account balances and try again."
        }
        
        showingAlert = true
    }
    
    private func clearForm() {
        fromAccount = nil
        toAccount = nil
        amount = ""
        notes = ""
        date = Date()
    }
    
    private func formatBalance(_ account: Account) -> String {
        let balance = account.currentBalance?.decimalValue ?? 0
        return formatCurrency(balance, currency: account.currency ?? "USD")
    }
    
    private func formatCurrency(_ amount: Decimal, currency: String = "USD") -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "0.00"
    }
}

#Preview {
    TransferView(
        accountService: AccountService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview))
    )
}