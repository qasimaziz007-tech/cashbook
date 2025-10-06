import Foundation

public enum TransactionType: String, CaseIterable, Identifiable {
    case income = "income"
    case expense = "expense"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .income:
            return "Income"
        case .expense:
            return "Expense"
        }
    }
    
    public var systemImageName: String {
        switch self {
        case .income:
            return "arrow.up.circle.fill"
        case .expense:
            return "arrow.down.circle.fill"
        }
    }
}