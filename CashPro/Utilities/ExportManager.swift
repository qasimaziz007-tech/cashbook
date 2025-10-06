//
//  ExportManager.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ExportManager {
    
    static let shared = ExportManager()
    
    private init() {}
    
    // MARK: - Export Transactions
    
    func exportTransactionsToCSV(_ transactions: [Transaction]) -> URL? {
        var csvString = "Date,Category,ID,Vendor,Account,Amount,Description,Type\n"
        
        for transaction in transactions {
            let dateString = Constants.shortDateFormatter.string(from: transaction.date)
            let category = transaction.category.replacingOccurrences(of: ",", with: ";")
            let transactionId = (transaction.transactionId ?? "").replacingOccurrences(of: ",", with: ";")
            let vendor = (transaction.vendor ?? "").replacingOccurrences(of: ",", with: ";")
            let account = transaction.account?.name ?? ""
            let amount = NSDecimalNumber(decimal: transaction.amount).stringValue
            let description = (transaction.desc ?? "").replacingOccurrences(of: ",", with: ";")
            let type = transaction.type
            
            csvString += "\(dateString),\(category),\(transactionId),\(vendor),\(account),\(amount),\(description),\(type)\n"
        }
        
        return saveStringToFile(csvString, fileName: "transactions_\(Date().timeIntervalSince1970).csv")
    }
    
    // MARK: - Export Employees
    
    func exportEmployeesToCSV(_ employees: [Employee]) -> URL? {
        var csvString = "Name,Designation,Phone,Email,Emirates ID,Join Date,Salary,Visa Expiry\n"
        
        for employee in employees {
            let name = employee.name?.replacingOccurrences(of: ",", with: ";") ?? ""
            let designation = (employee.designation ?? "").replacingOccurrences(of: ",", with: ";")
            let phone = employee.phone ?? ""
            let email = (employee.email ?? "").replacingOccurrences(of: ",", with: ";")
            let emiratesId = employee.emiratesId ?? ""
            let joinDate = Constants.shortDateFormatter.string(from: employee.joinDate)
            let salary = NSDecimalNumber(decimal: employee.salary).stringValue
            let visaExpiry = employee.visaExpiry != nil ? Constants.shortDateFormatter.string(from: employee.visaExpiry!) : ""
            
            csvString += "\(name),\(designation),\(phone),\(email),\(emiratesId),\(joinDate),\(salary),\(visaExpiry)\n"
        }
        
        return saveStringToFile(csvString, fileName: "employees_\(Date().timeIntervalSince1970).csv")
    }
    
    // MARK: - Export Parts
    
    func exportPartsToCSV(_ parts: [Part]) -> URL? {
        var csvString = "Part Name,Part Number,Customer,Vehicle,Supplier,Quantity,Price\n"
        
        for part in parts {
            let partName = part.partName?.replacingOccurrences(of: ",", with: ";") ?? ""
            let partNumber = (part.partNumber ?? "").replacingOccurrences(of: ",", with: ";")
            let customer = (part.customer ?? "").replacingOccurrences(of: ",", with: ";")
            let vehicle = (part.vehicle ?? "").replacingOccurrences(of: ",", with: ";")
            let supplier = (part.supplier ?? "").replacingOccurrences(of: ",", with: ";")
            let quantity = String(part.quantity)
            let price = NSDecimalNumber(decimal: part.price).stringValue
            
            csvString += "\(partName),\(partNumber),\(customer),\(vehicle),\(supplier),\(quantity),\(price)\n"
        }
        
        return saveStringToFile(csvString, fileName: "parts_\(Date().timeIntervalSince1970).csv")
    }
    
    // MARK: - Backup All Data
    
    func backupAllData() -> URL? {
        let coreDataManager = CoreDataManager.shared
        
        let backupData: [String: Any] = [
            "transactions": exportTransactionsData(coreDataManager.fetchTransactions()),
            "employees": exportEmployeesData(coreDataManager.fetchEmployees()),
            "parts": exportPartsData(coreDataManager.fetchParts()),
            "accounts": exportAccountsData(coreDataManager.fetchAccounts()),
            "users": exportUsersData(coreDataManager.fetchUsers()),
            "exportDate": Date().timeIntervalSince1970,
            "appVersion": "1.0",
            "companyName": Constants.companyName,
            "companyAddress": Constants.companyAddress
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: backupData, options: .prettyPrinted)
            let jsonString = String(data: jsonData, encoding: .utf8) ?? ""
            return saveStringToFile(jsonString, fileName: "cashpro_backup_\(Date().timeIntervalSince1970).json")
        } catch {
            print("Error creating backup: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveStringToFile(_ string: String, fileName: String) -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        do {
            try string.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving file: \(error)")
            return nil
        }
    }
    
    // MARK: - Data Export Helpers
    
    private func exportTransactionsData(_ transactions: [Transaction]) -> [[String: Any]] {
        return transactions.map { transaction in
            return [
                "id": transaction.id?.uuidString ?? "",
                "date": transaction.date.timeIntervalSince1970,
                "category": transaction.category ?? "",
                "transactionId": transaction.transactionId ?? "",
                "vendor": transaction.vendor ?? "",
                "account": transaction.account?.name ?? "",
                "amount": NSDecimalNumber(decimal: transaction.amount).doubleValue,
                "description": transaction.desc ?? "",
                "type": transaction.type ?? "",
                "createdAt": transaction.createdAt.timeIntervalSince1970,
                "createdBy": transaction.createdBy ?? ""
            ]
        }
    }
    
    private func exportEmployeesData(_ employees: [Employee]) -> [[String: Any]] {
        return employees.map { employee in
            return [
                "id": employee.id?.uuidString ?? "",
                "name": employee.name ?? "",
                "designation": employee.designation ?? "",
                "phone": employee.phone ?? "",
                "email": employee.email ?? "",
                "emiratesId": employee.emiratesId ?? "",
                "joinDate": employee.joinDate.timeIntervalSince1970,
                "salary": NSDecimalNumber(decimal: employee.salary).doubleValue,
                "visaExpiry": employee.visaExpiry?.timeIntervalSince1970 ?? 0
            ]
        }
    }
    
    private func exportPartsData(_ parts: [Part]) -> [[String: Any]] {
        return parts.map { part in
            return [
                "id": part.id?.uuidString ?? "",
                "partName": part.partName ?? "",
                "partNumber": part.partNumber ?? "",
                "customer": part.customer ?? "",
                "vehicle": part.vehicle ?? "",
                "supplier": part.supplier ?? "",
                "quantity": Int(part.quantity),
                "price": NSDecimalNumber(decimal: part.price).doubleValue
            ]
        }
    }
    
    private func exportAccountsData(_ accounts: [Account]) -> [[String: Any]] {
        return accounts.map { account in
            return [
                "id": account.id?.uuidString ?? "",
                "name": account.name ?? ""
            ]
        }
    }
    
    private func exportUsersData(_ users: [User]) -> [[String: Any]] {
        return users.map { user in
            return [
                "id": user.id?.uuidString ?? "",
                "username": user.username ?? "",
                "role": user.role ?? "",
                // Note: We don't export passwords for security reasons
                "hasPassword": !user.password.isEmpty
            ]
        }
    }
    
    // MARK: - Share File
    
    func shareFile(_ fileURL: URL, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        // For iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.frame.size.width / 2,
                                      y: viewController.view.frame.size.height / 2,
                                      width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(activityViewController, animated: true)
    }
}