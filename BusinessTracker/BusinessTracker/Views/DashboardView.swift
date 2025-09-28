import SwiftUI
import Charts

public struct DashboardView: View {
    @ObservedObject var businessService: BusinessService
    @ObservedObject var transactionService: TransactionService
    @ObservedObject var accountService: AccountService
    
    @State private var selectedPeriod: TimePeriod = .thisMonth
    
    public var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Business Header
                    BusinessHeaderCard(business: businessService.activeBusiness)
                    
                    // Period Selector
                    PeriodSelector(selectedPeriod: $selectedPeriod)
                    
                    // Summary Cards
                    SummaryCardsView(
                        transactionService: transactionService,
                        accountService: accountService,
                        period: selectedPeriod
                    )
                    
                    // Recent Transactions
                    RecentTransactionsCard(
                        transactions: Array(transactionService.transactions.prefix(5))
                    )
                    
                    // Account Balances
                    AccountBalancesCard(accounts: accountService.accounts)
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .refreshable {
                refreshData()
            }
        }
    }
    
    private func refreshData() {
        transactionService.loadTransactions()
        accountService.loadAccounts()
    }
}

struct BusinessHeaderCard: View {
    let business: Business?
    
    var body: some View {
        if let business = business {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "building.2.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(business.name ?? "Business")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if let address = business.address {
                            Text(address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Text(business.currency ?? "USD")
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
    }
}

struct PeriodSelector: View {
    @Binding var selectedPeriod: TimePeriod
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        selectedPeriod = period
                    }) {
                        Text(period.displayName)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(selectedPeriod == period ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedPeriod == period ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SummaryCardsView: View {
    @ObservedObject var transactionService: TransactionService
    @ObservedObject var accountService: AccountService
    let period: TimePeriod
    
    var body: some View {
        let dateRange = period.dateInterval
        let totalIncome = transactionService.getTotalIncome(for: dateRange)
        let totalExpense = transactionService.getTotalExpense(for: dateRange)
        let netIncome = totalIncome - totalExpense
        let totalBalance = accountService.getTotalBalance()
        
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            SummaryCard(
                title: "Income",
                value: totalIncome,
                color: .green,
                icon: "arrow.up.circle.fill"
            )
            
            SummaryCard(
                title: "Expense",
                value: totalExpense,
                color: .red,
                icon: "arrow.down.circle.fill"
            )
            
            SummaryCard(
                title: "Net Income",
                value: netIncome,
                color: netIncome >= 0 ? .green : .red,
                icon: "equal.circle.fill"
            )
            
            SummaryCard(
                title: "Total Balance",
                value: totalBalance,
                color: .blue,
                icon: "dollarsign.circle.fill"
            )
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: Decimal
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatCurrency(value))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD" // Should be dynamic based on business currency
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
}

struct RecentTransactionsCard: View {
    let transactions: [Transaction]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("View All") {
                    // TODO: Navigate to transactions view
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            if transactions.isEmpty {
                Text("No transactions yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(transactions, id: \.id) { transaction in
                    TransactionRowView(transaction: transaction)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct AccountBalancesCard: View {
    let accounts: [Account]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Balances")
                .font(.headline)
                .fontWeight(.semibold)
            
            if accounts.isEmpty {
                Text("No accounts created yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(accounts, id: \.id) { account in
                    AccountRowView(account: account)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack {
            Image(systemName: transactionType.systemImageName)
                .foregroundColor(transactionType == .income ? .green : .red)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(transaction.account?.name ?? "Unknown Account")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatCurrency(transaction.amount?.decimalValue ?? 0))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(transactionType == .income ? .green : .red)
                
                Text(formatDate(transaction.date))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private var transactionType: TransactionType {
        TransactionType(rawValue: transaction.type ?? "") ?? .expense
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "$0.00"
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct AccountRowView: View {
    let account: Account
    
    var body: some View {
        HStack {
            Image(systemName: "creditcard.fill")
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(account.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(account.currency ?? "USD")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(formatCurrency(account.currentBalance?.decimalValue ?? 0))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(account.currentBalance?.decimalValue ?? 0 >= 0 ? .green : .red)
        }
        .padding(.vertical, 4)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = account.currency ?? "USD"
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "0.00"
    }
}

enum TimePeriod: CaseIterable {
    case today
    case thisWeek
    case thisMonth
    case thisYear
    case all
    
    var displayName: String {
        switch self {
        case .today: return "Today"
        case .thisWeek: return "This Week"
        case .thisMonth: return "This Month"
        case .thisYear: return "This Year"
        case .all: return "All Time"
        }
    }
    
    var dateInterval: DateInterval? {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .today:
            let startOfDay = calendar.startOfDay(for: now)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            return DateInterval(start: startOfDay, end: endOfDay)
            
        case .thisWeek:
            let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
            let endOfWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfWeek)!
            return DateInterval(start: startOfWeek, end: endOfWeek)
            
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start ?? now
            let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth)!
            return DateInterval(start: startOfMonth, end: endOfMonth)
            
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start ?? now
            let endOfYear = calendar.date(byAdding: .year, value: 1, to: startOfYear)!
            return DateInterval(start: startOfYear, end: endOfYear)
            
        case .all:
            return nil
        }
    }
}

#Preview {
    DashboardView(
        businessService: BusinessService(persistenceController: .preview),
        transactionService: TransactionService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview)),
        accountService: AccountService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview))
    )
}