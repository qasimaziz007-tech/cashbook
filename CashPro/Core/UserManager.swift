//
//  UserManager.swift
//  CashPro
//
//  Created on 2024
//  Copyright © 2024 Esthetics Auto. All rights reserved.
//

import Foundation
import CoreData

class UserManager {
    
    static let shared = UserManager()
    
    private init() {}
    
    private var currentUser: User?
    
    // MARK: - Authentication
    
    func login(username: String, password: String) -> Bool {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        do {
            let users = try context.fetch(request)
            if let user = users.first {
                currentUser = user
                UserDefaults.standard.set(username, forKey: Constants.UserDefaultsKeys.currentUserUsername)
                UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLoggedIn)
                return true
            }
        } catch {
            print("Error during login: \(error)")
        }
        
        return false
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.currentUserUsername)
        UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKeys.isLoggedIn)
    }
    
    func isUserLoggedIn() -> Bool {
        if UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isLoggedIn) {
            // Try to restore current user
            if let username = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.currentUserUsername) {
                return restoreCurrentUser(username: username)
            }
        }
        return false
    }
    
    private func restoreCurrentUser(username: String) -> Bool {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let users = try context.fetch(request)
            if let user = users.first {
                currentUser = user
                return true
            }
        } catch {
            print("Error restoring current user: \(error)")
        }
        
        // If user not found, clear login status
        logout()
        return false
    }
    
    // MARK: - Current User
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func getCurrentUsername() -> String {
        return currentUser?.username ?? "Unknown"
    }
    
    func getCurrentUserRole() -> Constants.UserRole {
        guard let roleString = currentUser?.role else {
            return .user
        }
        return Constants.UserRole(rawValue: roleString) ?? .user
    }
    
    func isCurrentUserAdmin() -> Bool {
        return getCurrentUserRole() == .admin
    }
    
    // MARK: - User Management
    
    func createUser(username: String, password: String, role: Constants.UserRole) -> Bool {
        let context = CoreDataManager.shared.context
        
        // Check if username already exists
        let request: NSFetchRequest<User> = User.fetchRequest()
        request.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let existingUsers = try context.fetch(request)
            if !existingUsers.isEmpty {
                return false // Username already exists
            }
            
            // Create new user
            let newUser = User(context: context)
            newUser.id = UUID()
            newUser.username = username
            newUser.password = password
            newUser.role = role.rawValue
            
            CoreDataManager.shared.saveContext()
            return true
            
        } catch {
            print("Error creating user: \(error)")
            return false
        }
    }
    
    func deleteUser(_ user: User) -> Bool {
        // Prevent deletion of current user
        if user == currentUser {
            return false
        }
        
        // Prevent deletion of admin if current user is not admin
        if user.role == Constants.UserRole.admin.rawValue && !isCurrentUserAdmin() {
            return false
        }
        
        CoreDataManager.shared.delete(user)
        return true
    }
    
    func changePassword(currentPassword: String, newPassword: String) -> Bool {
        guard let user = currentUser else { return false }
        
        if user.password == currentPassword {
            user.password = newPassword
            CoreDataManager.shared.saveContext()
            return true
        }
        
        return false
    }
    
    // MARK: - Permission Checks
    
    func canEditTransaction(_ transaction: Transaction) -> Bool {
        guard let user = currentUser else { return false }
        
        // Admin can edit any transaction
        if user.role == Constants.UserRole.admin.rawValue {
            return true
        }
        
        // User can edit their own transaction within 10 minutes
        if transaction.createdBy == user.username {
            let tenMinutesAgo = Date().addingTimeInterval(-10 * 60)
            return transaction.createdAt > tenMinutesAgo
        }
        
        return false
    }
    
    func canDeleteTransaction(_ transaction: Transaction) -> Bool {
        return canEditTransaction(transaction)
    }
    
    func canManageEmployees() -> Bool {
        return isCurrentUserAdmin()
    }
    
    func canManageUsers() -> Bool {
        return isCurrentUserAdmin()
    }
    
    func canExportData() -> Bool {
        return isCurrentUserAdmin()
    }
    
    func canBackupRestoreData() -> Bool {
        return isCurrentUserAdmin()
    }
}