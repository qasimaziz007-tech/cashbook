import Foundation

public struct Currency: Identifiable, Codable {
    public let id = UUID()
    public let code: String
    public let name: String
    public let symbol: String
    
    public init(code: String, name: String, symbol: String) {
        self.code = code
        self.name = name
        self.symbol = symbol
    }
    
    public static let supportedCurrencies: [Currency] = [
        Currency(code: "USD", name: "US Dollar", symbol: "$"),
        Currency(code: "EUR", name: "Euro", symbol: "€"),
        Currency(code: "GBP", name: "British Pound", symbol: "£"),
        Currency(code: "AED", name: "UAE Dirham", symbol: "د.إ"),
        Currency(code: "SAR", name: "Saudi Riyal", symbol: "ر.س"),
        Currency(code: "INR", name: "Indian Rupee", symbol: "₹"),
        Currency(code: "CAD", name: "Canadian Dollar", symbol: "C$"),
        Currency(code: "AUD", name: "Australian Dollar", symbol: "A$"),
        Currency(code: "JPY", name: "Japanese Yen", symbol: "¥"),
        Currency(code: "CHF", name: "Swiss Franc", symbol: "Fr"),
    ]
    
    public static func getCurrency(by code: String) -> Currency? {
        return supportedCurrencies.first { $0.code == code }
    }
    
    public func formatAmount(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        formatter.currencySymbol = symbol
        
        return formatter.string(from: NSDecimalNumber(decimal: amount)) ?? "\(symbol)\(amount)"
    }
}