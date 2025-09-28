import CoreData
import Foundation

public class BusinessService: ObservableObject {
    private let persistenceController: PersistenceController
    
    @Published public var activeBusiness: Business?
    @Published public var businesses: [Business] = []
    
    public init(persistenceController: PersistenceController = .shared) {
        self.persistenceController = persistenceController
        loadBusinesses()
        setActiveBusiness()
    }
    
    public func loadBusinesses() {
        let request: NSFetchRequest<Business> = Business.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Business.name, ascending: true)]
        
        do {
            businesses = try persistenceController.container.viewContext.fetch(request)
        } catch {
            print("Error loading businesses: \(error)")
        }
    }
    
    public func createBusiness(name: String, address: String?, currency: String) -> Business {
        let context = persistenceController.container.viewContext
        let business = Business(context: context)
        
        business.id = UUID()
        business.name = name
        business.address = address
        business.currency = currency
        business.isActive = businesses.isEmpty // First business is automatically active
        business.createdAt = Date()
        business.updatedAt = Date()
        
        // Create default categories
        createDefaultCategories(for: business)
        
        // Create default payment modes
        createDefaultPaymentModes(for: business)
        
        do {
            try context.save()
            loadBusinesses()
            if business.isActive {
                activeBusiness = business
            }
            logActivity(business: business, action: "Business Created", details: "Business '\(name)' was created")
            return business
        } catch {
            print("Error creating business: \(error)")
            context.rollback()
            return business
        }
    }
    
    public func setActiveBusiness(_ business: Business? = nil) {
        let context = persistenceController.container.viewContext
        
        // Deactivate all businesses
        for b in businesses {
            b.isActive = false
        }
        
        // Set the new active business
        if let business = business {
            business.isActive = true
            activeBusiness = business
        } else {
            // Set first business as active if none specified
            activeBusiness = businesses.first
            activeBusiness?.isActive = true
        }
        
        do {
            try context.save()
            loadBusinesses()
        } catch {
            print("Error updating active business: \(error)")
        }
    }
    
    public func updateBusiness(_ business: Business, name: String, address: String?, currency: String) {
        let context = persistenceController.container.viewContext
        
        business.name = name
        business.address = address
        business.currency = currency
        business.updatedAt = Date()
        
        do {
            try context.save()
            loadBusinesses()
            logActivity(business: business, action: "Business Updated", details: "Business details updated")
        } catch {
            print("Error updating business: \(error)")
        }
    }
    
    public func deleteBusiness(_ business: Business) {
        let context = persistenceController.container.viewContext
        
        // If this is the active business, set another one as active
        if business.isActive && businesses.count > 1 {
            let otherBusiness = businesses.first { $0 != business }
            otherBusiness?.isActive = true
            activeBusiness = otherBusiness
        } else if business.isActive {
            activeBusiness = nil
        }
        
        context.delete(business)
        
        do {
            try context.save()
            loadBusinesses()
        } catch {
            print("Error deleting business: \(error)")
        }
    }
    
    private func createDefaultCategories(for business: Business) {
        let defaultCategories = ["Sales", "Purchase", "Salary", "Rent", "Fuel", "Maintenance", "Other"]
        let context = persistenceController.container.viewContext
        
        for categoryName in defaultCategories {
            let category = Category(context: context)
            category.id = UUID()
            category.name = categoryName
            category.createdAt = Date()
            category.business = business
        }
    }
    
    private func createDefaultPaymentModes(for business: Business) {
        let defaultPaymentModes = ["Cash", "Bank Transfer", "Credit Card", "Debit Card", "Cheque"]
        let context = persistenceController.container.viewContext
        
        for modeName in defaultPaymentModes {
            let paymentMode = PaymentMode(context: context)
            paymentMode.id = UUID()
            paymentMode.name = modeName
            paymentMode.createdAt = Date()
            paymentMode.business = business
        }
    }
    
    private func logActivity(business: Business, action: String, details: String) {
        let context = persistenceController.container.viewContext
        let log = ActivityLog(context: context)
        
        log.id = UUID()
        log.action = action
        log.details = details
        log.timestamp = Date()
        log.business = business
        
        try? context.save()
    }
}