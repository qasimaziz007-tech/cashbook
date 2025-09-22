//
//  Constants.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    // MARK: - App Info
    static let appName = "CashPro"
    static let companyName = "Esthetics Auto"
    static let companyAddress = "Dubai, UAE"
    static let currency = "AED"
    
    // MARK: - Colors
    struct Colors {
        static let brand = UIColor(red: 0.043, green: 0.231, blue: 0.427, alpha: 1.0) // #0b3b6d
        static let brandSecondary = UIColor(red: 0.118, green: 0.435, blue: 0.851, alpha: 1.0) // #1e6fd9
        static let background = UIColor(red: 0.957, green: 0.965, blue: 0.976, alpha: 1.0) // #f4f6f9
        static let cardBackground = UIColor.white
        static let textPrimary = UIColor(red: 0.122, green: 0.161, blue: 0.216, alpha: 1.0) // #1f2937
        static let textSecondary = UIColor(red: 0.420, green: 0.447, blue: 0.502, alpha: 1.0) // #6b7280
        static let danger = UIColor(red: 0.863, green: 0.208, blue: 0.271, alpha: 1.0) // #dc3545
        static let success = UIColor(red: 0.086, green: 0.639, blue: 0.290, alpha: 1.0) // #16a34a
        static let warning = UIColor(red: 0.963, green: 0.620, blue: 0.043, alpha: 1.0) // #f59e0b
        static let income = UIColor(red: 0.086, green: 0.639, blue: 0.290, alpha: 1.0) // Success green
        static let expense = UIColor(red: 0.863, green: 0.149, blue: 0.149, alpha: 1.0) // #dc2626
    }
    
    // MARK: - Transaction Types
    enum TransactionType: String, CaseIterable {
        case income = "income"
        case expense = "expense"
        
        var displayName: String {
            return self.rawValue.capitalized
        }
        
        var color: UIColor {
            switch self {
            case .income:
                return Colors.income
            case .expense:
                return Colors.expense
            }
        }
    }
    
    // MARK: - User Roles
    enum UserRole: String, CaseIterable {
        case admin = "admin"
        case user = "user"
        
        var displayName: String {
            return self.rawValue.capitalized
        }
    }
    
    // MARK: - Attendance Status
    enum AttendanceStatus: String, CaseIterable {
        case present = "present"
        case absent = "absent"
        case leave = "leave"
        
        var displayName: String {
            return self.rawValue.capitalized
        }
        
        var color: UIColor {
            switch self {
            case .present:
                return Colors.success
            case .absent:
                return Colors.danger
            case .leave:
                return Colors.brandSecondary
            }
        }
    }
    
    // MARK: - Advance Status
    enum AdvanceStatus: String, CaseIterable {
        case pending = "pending"
        case paid = "paid"
        
        var displayName: String {
            return self.rawValue.capitalized
        }
        
        var color: UIColor {
            switch self {
            case .pending:
                return Colors.warning
            case .paid:
                return Colors.success
            }
        }
    }
    
    // MARK: - Default Categories
    static let defaultCategories = [
        "Sales", "Purchase", "Salary", "Rent", "Fuel", "Maintenance", "Other"
    ]
    
    // MARK: - Default Accounts
    static let defaultAccounts = [
        "Cash", "Bank", "Credit Card"
    ]
    
    // MARK: - UserDefaults Keys
    struct UserDefaultsKeys {
        static let currentUserUsername = "currentUserUsername"
        static let isLoggedIn = "isLoggedIn"
        static let categories = "categories"
        static let accounts = "accounts"
        static let companySettings = "companySettings"
    }
    
    // MARK: - Storyboard Identifiers
    struct StoryboardIDs {
        static let mainTabBarController = "MainTabBarController"
        static let loginViewController = "LoginViewController"
        static let dashboardViewController = "DashboardViewController"
        static let transactionsViewController = "TransactionsViewController"
        static let employeesViewController = "EmployeesViewController"
        static let partsViewController = "PartsViewController"
        static let settingsViewController = "SettingsViewController"
    }
    
    // MARK: - Formatters
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "AED "
        formatter.maximumFractionDigits = 2
        return formatter
    }()
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        return formatter
    }()
    
    static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
}