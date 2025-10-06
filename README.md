# Business Tracker iOS App

A comprehensive iOS application for managing business transactions, financial accounts, and related data. Built with Swift, SwiftUI, and Core Data for local data persistence.

## Features

### Getting Started
- ✅ Add and manage multiple businesses
- ✅ Set an active business
- ✅ Create accounts with currency and opening balances

### Daily Use
- ✅ Add, edit, and delete transactions (income and expense)
- ✅ Transaction fields: account, amount, category, payment mode, optional notes
- ✅ Adjust date and time for past transactions

### Fund Transfers
- ✅ Transfer money between accounts with automatic logging
- ✅ Balance validation and automatic updates

### Categories & Payment Modes
- ✅ Organize transactions using categories and payment modes
- ✅ Auto-create missing categories/payment modes during imports

### Export CSV/Excel
- ✅ Export transactions in CSV format
- ✅ Comprehensive columns for analysis

### Backup & Restore
- ✅ JSON backups for secure storage and sharing
- ✅ Restore data from backups (replaces current data)

### Import from CSV
- ✅ Support CSV imports with header and data validation
- ✅ Auto-create missing accounts/categories/payment modes

### Activity Logs
- ✅ Automatic logging of all major actions
- ✅ Filter logs by date ranges (future enhancement)

### Multi-Business Support
- ✅ Maintain separate data for each business
- ✅ Scope imports, exports, and reports to active business

### Currency Management
- ✅ Support for multiple currencies
- ✅ Accounts can operate in different currencies
- ✅ Display data in respective account currencies

### Privacy
- ✅ All data stored locally on device
- ✅ No external sharing or cloud storage
- ✅ Complete privacy and security

## Technical Architecture

### Core Data Model
- **Business**: Main entity containing all business-related data
- **Account**: Financial accounts with currency and balance tracking
- **Transaction**: Income/expense transactions with full details
- **Category**: Transaction categorization
- **PaymentMode**: Payment method tracking
- **FundTransfer**: Inter-account transfer logging
- **ActivityLog**: Comprehensive activity tracking

### Services Layer
- **BusinessService**: Manages business entities and active business
- **AccountService**: Handles account operations and fund transfers
- **TransactionService**: Manages all transaction operations
- **ImportExportService**: Handles CSV/JSON import/export functionality

### UI Architecture
- **SwiftUI**: Modern declarative UI framework
- **MVVM Pattern**: Clean separation of concerns
- **Responsive Design**: Adapts to different iOS device sizes
- **Accessibility**: Built-in accessibility support

## Requirements

- iOS 16.0+
- Xcode 14.0+
- Swift 5.9+

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run on your iOS device or simulator

## Usage

### First Launch
1. Enter your business name and details
2. Select your preferred currency
3. The app will create default categories and payment modes

### Adding Accounts
1. Go to the Accounts tab
2. Tap the "+" button
3. Enter account name, currency, and opening balance

### Recording Transactions
1. Go to the Transactions tab
2. Tap the "+" button
3. Fill in transaction details:
   - Amount
   - Type (Income/Expense)
   - Account
   - Category
   - Payment mode (optional)
   - Notes (optional)
   - Date and time

### Fund Transfers
1. Go to the Transfer tab
2. Select source and destination accounts
3. Enter transfer amount and optional notes
4. The system will validate sufficient balance

### Import/Export
1. Go to Settings
2. Use "Export Transactions (CSV)" to export data
3. Use "Create Backup (JSON)" for complete data backup
4. Use "Import Transactions (CSV)" to import data
5. Use "Restore from Backup (JSON)" to restore complete data

### CSV Import Format
```csv
Date,Category,Account,Amount,Type,Payment Mode,Notes
01-12-2023,Sales,Cash,1000.00,income,Cash,Product sales
02-12-2023,Rent,Bank,2000.00,expense,Bank Transfer,Office rent
```

## Data Security

- All data is stored locally using Core Data
- No internet connection required for core functionality
- No data is transmitted to external servers
- Backups are created locally and can be shared manually

## Development

### Running Tests
```bash
swift test
```

### Building for Release
1. Select your target device/simulator
2. Choose Product → Archive
3. Follow the distribution workflow

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues, feature requests, or questions, please create an issue in the GitHub repository.