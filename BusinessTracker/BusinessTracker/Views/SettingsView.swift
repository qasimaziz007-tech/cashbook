import SwiftUI

public struct SettingsView: View {
    @ObservedObject var businessService: BusinessService
    @ObservedObject var importExportService: ImportExportService
    
    @State private var showingBusinessPicker = false
    @State private var showingImportPicker = false
    @State private var showingExportShare = false
    @State private var exportData: Data?
    @State private var csvContent: String?
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    public var body: some View {
        NavigationView {
            List {
                // Business Section
                Section("Business") {
                    if let activeBusiness = businessService.activeBusiness {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(activeBusiness.name ?? "Unknown")
                                    .font(.headline)
                                
                                if let address = activeBusiness.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text(activeBusiness.currency ?? "USD")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    
                    if businessService.businesses.count > 1 {
                        Button("Switch Business") {
                            showingBusinessPicker = true
                        }
                    }
                }
                
                // Export Section
                Section("Export") {
                    Button("Export Transactions (CSV)") {
                        exportCSV()
                    }
                    
                    Button("Create Backup (JSON)") {
                        createBackup()
                    }
                }
                
                // Import Section
                Section("Import") {
                    Button("Import Transactions (CSV)") {
                        showingImportPicker = true
                    }
                    
                    Button("Restore from Backup (JSON)") {
                        // TODO: Implement file picker for JSON restore
                    }
                }
                
                // Privacy Section
                Section("Privacy & Security") {
                    HStack {
                        Image(systemName: "lock.shield")
                            .foregroundColor(.green)
                        
                        VStack(alignment: .leading) {
                            Text("Local Storage Only")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Text("All your data is stored locally on your device and never shared externally.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingBusinessPicker) {
                BusinessPickerView(businessService: businessService)
            }
            .fileImporter(
                isPresented: $showingImportPicker,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleCSVImport(result)
            }
            .sheet(isPresented: $showingExportShare) {
                if let data = exportData {
                    ShareSheet(items: [data])
                } else if let content = csvContent {
                    ShareSheet(items: [content])
                }
            }
            .alert("Result", isPresented: $showingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    private func exportCSV() {
        if let content = importExportService.exportTransactionsToCSV() {
            csvContent = content
            showingExportShare = true
        } else {
            alertMessage = "No transactions to export"
            showingAlert = true
        }
    }
    
    private func createBackup() {
        if let data = importExportService.createBackup() {
            exportData = data
            showingExportShare = true
        } else {
            alertMessage = "Failed to create backup"
            showingAlert = true
        }
    }
    
    private func handleCSVImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let content = try String(contentsOf: url)
                let result = importExportService.importTransactionsFromCSV(content)
                
                if result.success {
                    alertMessage = "Import successful! \(result.importedCount) transactions imported, \(result.skippedCount) skipped."
                } else {
                    alertMessage = "Import failed: \(result.errors.joined(separator: ", "))"
                }
            } catch {
                alertMessage = "Failed to read file: \(error.localizedDescription)"
            }
            
            showingAlert = true
            
        case .failure(let error):
            alertMessage = "File selection failed: \(error.localizedDescription)"
            showingAlert = true
        }
    }
}

struct BusinessPickerView: View {
    @ObservedObject var businessService: BusinessService
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(businessService.businesses, id: \.id) { business in
                    Button(action: {
                        businessService.setActiveBusiness(business)
                        dismiss()
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(business.name ?? "Unknown")
                                    .foregroundColor(.primary)
                                
                                if let address = business.address {
                                    Text(address)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if business.isActive {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Business")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    SettingsView(
        businessService: BusinessService(persistenceController: .preview),
        importExportService: ImportExportService(
            persistenceController: .preview,
            businessService: BusinessService(persistenceController: .preview),
            transactionService: TransactionService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview)),
            accountService: AccountService(persistenceController: .preview, businessService: BusinessService(persistenceController: .preview))
        )
    )
}