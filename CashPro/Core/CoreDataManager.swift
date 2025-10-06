//
//  CoreDataManager.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private init() {
        // Initialize default data on first launch
        setupDefaultData()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CashPro")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    // MARK: - Setup Default Data
    
    private func setupDefaultData() {
        setupDefaultAdmin()
        setupDefaultAccounts()
    }
    
    private func setupDefaultAdmin() {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", "admin")
        
        do {
            let existingUsers = try context.fetch(request)
            if existingUsers.isEmpty {
                let adminUser = User(context: context)
                adminUser.id = UUID()
                adminUser.username = "admin"
                adminUser.password = "admin"
                adminUser.role = Constants.UserRole.admin.rawValue
                
                saveContext()
                print("Default admin user created")
            }
        } catch {
            print("Error checking for default admin: \(error)")
        }
    }
    
    private func setupDefaultAccounts() {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        
        do {
            let existingAccounts = try context.fetch(request)
            if existingAccounts.isEmpty {
                for accountName in Constants.defaultAccounts {
                    let account = Account(context: context)
                    account.id = UUID()
                    account.name = accountName
                }
                
                saveContext()
                print("Default accounts created")
            }
        } catch {
            print("Error checking for default accounts: \(error)")
        }
    }
    
    // MARK: - Fetch Methods
    
    func fetchUsers() -> [User] {
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
    
    func fetchAccounts() -> [Account] {
        let request: NSFetchRequest<Account> = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching accounts: \(error)")
            return []
        }
    }
    
    func fetchTransactions() -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching transactions: \(error)")
            return []
        }
    }
    
    func fetchEmployees() -> [Employee] {
        let request: NSFetchRequest<Employee> = Employee.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching employees: \(error)")
            return []
        }
    }
    
    func fetchParts() -> [Part] {
        let request: NSFetchRequest<Part> = Part.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "partName", ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching parts: \(error)")
            return []
        }
    }
    
    // MARK: - Delete Methods
    
    func delete<T: NSManagedObject>(_ object: T) {
        context.delete(object)
        saveContext()
    }
    
    func deleteAllData() {
        let entities = ["Transaction", "Employee", "Part", "Payroll", "Advance", "Attendance"]
        
        for entityName in entities {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Error deleting \(entityName): \(error)")
            }
        }
        
        saveContext()
    }
    
    // MARK: - Statistics Methods
    
    func getTotalBalance() -> Decimal {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        do {
            let transactions = try context.fetch(request)
            var total: Decimal = 0
            
            for transaction in transactions {
                if transaction.type == Constants.TransactionType.income.rawValue {
                    total += transaction.amount
                } else {
                    total -= transaction.amount
                }
            }
            
            return total
        } catch {
            print("Error calculating total balance: \(error)")
            return 0
        }
    }
    
    func getTodayTransactions() -> [Transaction] {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching today's transactions: \(error)")
            return []
        }
    }
}