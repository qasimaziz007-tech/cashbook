import SwiftUI

public struct BusinessSetupView: View {
    @ObservedObject var businessService: BusinessService
    
    @State private var businessName = ""
    @State private var businessAddress = ""
    @State private var selectedCurrency = Currency.supportedCurrencies[0]
    @State private var showingError = false
    @State private var errorMessage = ""
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    
                    Text("Welcome to Business Tracker")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    
                    Text("Let's set up your first business to get started")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom)
                }
                .listRowBackground(Color.clear)
                
                Section("Business Information") {
                    TextField("Business Name", text: $businessName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Address (Optional)", text: $businessAddress, axis: .vertical)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .lineLimit(2...4)
                    
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
                }
                
                Section {
                    Button(action: createBusiness) {
                        HStack {
                            Spacer()
                            Text("Create Business")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                    .disabled(businessName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("Setup")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createBusiness() {
        let trimmedName = businessName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedName.isEmpty else {
            errorMessage = "Please enter a business name"
            showingError = true
            return
        }
        
        let trimmedAddress = businessAddress.trimmingCharacters(in: .whitespacesAndNewlines)
        let address = trimmedAddress.isEmpty ? nil : trimmedAddress
        
        let business = businessService.createBusiness(
            name: trimmedName,
            address: address,
            currency: selectedCurrency.code
        )
        
        if business.name == trimmedName {
            // Success - the ContentView will automatically switch to the main interface
        } else {
            errorMessage = "Failed to create business. Please try again."
            showingError = true
        }
    }
}

#Preview {
    BusinessSetupView(businessService: BusinessService(persistenceController: .preview))
}