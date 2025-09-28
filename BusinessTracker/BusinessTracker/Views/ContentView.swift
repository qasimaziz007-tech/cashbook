import SwiftUI
import CoreData

public struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var businessService = BusinessService()
    @StateObject private var transactionService: TransactionService
    @StateObject private var accountService: AccountService
    @StateObject private var importExportService: ImportExportService
    
    @State private var selectedTab = 0
    
    public init() {
        let businessService = BusinessService()
        let accountService = AccountService(businessService: businessService)
        let transactionService = TransactionService(businessService: businessService)
        let importExportService = ImportExportService(
            businessService: businessService,
            transactionService: transactionService,
            accountService: accountService
        )
        
        self._businessService = StateObject(wrappedValue: businessService)
        self._accountService = StateObject(wrappedValue: accountService)
        self._transactionService = StateObject(wrappedValue: transactionService)
        self._importExportService = StateObject(wrappedValue: importExportService)
    }
    
    public var body: some View {
        Group {
            if businessService.activeBusiness == nil && businessService.businesses.isEmpty {
                BusinessSetupView(businessService: businessService)
            } else {
                MainTabView(
                    businessService: businessService,
                    transactionService: transactionService,
                    accountService: accountService,
                    importExportService: importExportService,
                    selectedTab: $selectedTab
                )
            }
        }
        .onAppear {
            setupServices()
        }
    }
    
    private func setupServices() {
        businessService.loadBusinesses()
        if let activeBusiness = businessService.activeBusiness {
            accountService.loadAccounts()
            transactionService.loadTransactions()
        }
    }
}

struct MainTabView: View {
    let businessService: BusinessService
    let transactionService: TransactionService
    let accountService: AccountService
    let importExportService: ImportExportService
    
    @Binding var selectedTab: Int
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView(
                businessService: businessService,
                transactionService: transactionService,
                accountService: accountService
            )
            .tabItem {
                Image(systemName: "chart.pie.fill")
                Text("Dashboard")
            }
            .tag(0)
            
            TransactionsView(
                transactionService: transactionService,
                accountService: accountService,
                businessService: businessService
            )
            .tabItem {
                Image(systemName: "list.bullet")
                Text("Transactions")
            }
            .tag(1)
            
            AccountsView(
                accountService: accountService,
                businessService: businessService
            )
            .tabItem {
                Image(systemName: "creditcard.fill")
                Text("Accounts")
            }
            .tag(2)
            
            TransferView(
                accountService: accountService
            )
            .tabItem {
                Image(systemName: "arrow.left.arrow.right")
                Text("Transfer")
            }
            .tag(3)
            
            SettingsView(
                businessService: businessService,
                importExportService: importExportService
            )
            .tabItem {
                Image(systemName: "gear")
                Text("Settings")
            }
            .tag(4)
        }
        .accentColor(.blue)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}