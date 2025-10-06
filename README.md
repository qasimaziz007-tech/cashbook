# CashPro iOS App

A comprehensive financial management iOS application for Esthetics Auto, built with Swift and Core Data.

## Overview

CashPro is a native iOS application that provides complete financial record management for automotive businesses. It includes features for transaction tracking, employee management, parts inventory, user roles, and data export capabilities.

## Features

### 🔐 Authentication & User Management
- Secure login system with username/password
- Role-based access control (Admin/User)
- Default admin account (username: admin, password: admin)
- User creation and management (Admin only)

### 📊 Dashboard
- Real-time balance overview
- Today's income and expense summary
- Recent transactions display
- Intuitive financial statistics

### 💰 Transaction Management
- Add income and expense transactions
- Search and filter capabilities
- Transaction details with categories
- Edit/delete permissions based on user role and time constraints
- Real-time balance calculations

### 👥 Employee Management (Admin Only)
- Employee profiles with personal details
- Salary management
- Join date and visa expiry tracking
- Photo storage capability
- Export to CSV

### 🔧 Parts Management
- Parts inventory tracking
- Customer and vehicle associations
- Supplier information
- Price and quantity management
- Search functionality

### ⚙️ Settings & Data Management
- Password change functionality
- User account management (Admin only)
- Data backup and export
- Complete data clearing (Admin only)
- App information and logout

### 📤 Export Capabilities
- CSV export for transactions, employees, and parts
- Complete data backup in JSON format
- Share functionality with other apps

## Technical Architecture

### Core Data Model
The app uses Core Data for persistence with the following entities:
- **Transaction**: Financial records with amount, category, date, type
- **Account**: Financial accounts (Cash, Bank, Credit Card)
- **Employee**: Staff records with personal and work information
- **User**: App users with authentication credentials and roles
- **Part**: Inventory items with customer and supplier details
- **Payroll**: Employee salary records
- **Advance**: Employee advance payments
- **Attendance**: Employee attendance tracking

### App Structure
```
CashPro/
├── Controllers/           # View Controllers
├── Core/                 # Core Data and User Management
├── Models/               # Core Data Models (auto-generated)
├── Views/                # Custom UI Components
├── Utilities/            # Helper classes and constants
├── Assets.xcassets/      # App icons and colors
└── Base.lproj/          # Storyboards and localization
```

### Key Components
- **CoreDataManager**: Handles all Core Data operations
- **UserManager**: Manages authentication and permissions
- **ExportManager**: Handles data export and sharing
- **Constants**: App-wide constants, colors, and formatters

## Installation & Setup

### Requirements
- Xcode 15.0 or later
- iOS 17.0+ deployment target
- Swift 5.0+

### Setup Instructions
1. Open `CashPro.xcodeproj` in Xcode
2. Select your development team in project settings
3. Choose your target device or simulator
4. Build and run the project (⌘+R)

### Default Login
- **Username**: admin
- **Password**: admin

## Usage Guide

### First Launch
1. The app will create default data including:
   - Admin user account
   - Default accounts (Cash, Bank, Credit Card)
   - Sample categories

### Adding Transactions
1. Navigate to Transactions tab
2. Tap the "+" button
3. Enter transaction details
4. Select Income or Expense

### Managing Employees (Admin Only)
1. Navigate to Employees tab
2. Tap "+" to add new employee
3. Fill in employee details
4. Save and manage from the list

### Data Export
1. Go to Settings tab
2. Use "Backup All Data" for complete export
3. Individual sections have export buttons in their respective tabs
4. Share exported files via standard iOS sharing

### User Management (Admin Only)
1. Open Settings tab
2. Select "Manage Users"
3. Add new users or view existing ones
4. Assign Admin or User roles

## Security Features

- **Role-based Access**: Admin-only features are properly restricted
- **Time-based Editing**: Users can only edit their own transactions within 10 minutes
- **Secure Login**: Password-protected access
- **Data Privacy**: No sensitive data in exports (passwords excluded)

## Customization

### Company Branding
Update company information in `Constants.swift`:
```swift
static let companyName = "Your Company Name"
static let companyAddress = "Your Address"
static let currency = "YOUR_CURRENCY"
```

### Colors and Theme
Modify brand colors in `Constants.swift`:
```swift
struct Colors {
    static let brand = UIColor(red: R, green: G, blue: B, alpha: 1.0)
    // ... other colors
}
```

## Data Model Relationships

```
User ─────────┐
              │
Transaction ──┼── Account
              │
Employee ─────┼── Payroll
              │   ├── Advance
              │   └── Attendance
              │
Part ─────────┘
```

## Export Formats

### CSV Exports
- **Transactions**: Date, Category, ID, Vendor, Account, Amount, Description, Type
- **Employees**: Name, Designation, Phone, Email, Emirates ID, Join Date, Salary, Visa Expiry
- **Parts**: Part Name, Part Number, Customer, Vehicle, Supplier, Quantity, Price

### JSON Backup
Complete app data including all entities and metadata for full restoration capability.

## Troubleshooting

### Common Issues
1. **Build Errors**: Ensure Xcode version compatibility
2. **Core Data Issues**: Clean build folder (⌘+Shift+K)
3. **Interface Issues**: Verify storyboard connections
4. **Export Problems**: Check app permissions for file access

### Reset App Data
Admin users can clear all data through Settings > Clear All Data

## Future Enhancements

Potential features for future versions:
- Cloud synchronization
- Advanced reporting with charts
- Receipt photo capture
- Biometric authentication
- Multi-language support
- Dark mode theme
- Push notifications

## Support

For technical support or feature requests, please contact the development team.

## License

Copyright © 2024 Esthetics Auto. All rights reserved.

---

**CashPro** - Professional Financial Management for iOS