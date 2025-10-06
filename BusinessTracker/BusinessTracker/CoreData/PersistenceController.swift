import CoreData
import Foundation

class PersistenceController: ObservableObject {
    static let shared = PersistenceController()
    
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Create sample data for previews
        let sampleBusiness = Business(context: viewContext)
        sampleBusiness.id = UUID()
        sampleBusiness.name = "Sample Business"
        sampleBusiness.address = "123 Business St"
        sampleBusiness.currency = "USD"
        sampleBusiness.isActive = true
        sampleBusiness.createdAt = Date()
        sampleBusiness.updatedAt = Date()
        
        let sampleAccount = Account(context: viewContext)
        sampleAccount.id = UUID()
        sampleAccount.name = "Cash"
        sampleAccount.currency = "USD"
        sampleAccount.openingBalance = NSDecimalNumber(decimal: 1000.0)
        sampleAccount.currentBalance = NSDecimalNumber(decimal: 1500.0)
        sampleAccount.createdAt = Date()
        sampleAccount.updatedAt = Date()
        sampleAccount.business = sampleBusiness
        
        let sampleCategory = Category(context: viewContext)
        sampleCategory.id = UUID()
        sampleCategory.name = "Sales"
        sampleCategory.color = "blue"
        sampleCategory.createdAt = Date()
        sampleCategory.business = sampleBusiness
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        guard let modelURL = Bundle.main.url(forResource: "BusinessTracker", withExtension: "momd") else {
            fatalError("Failed to find data model")
        }
        
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Failed to load data model")
        }
        
        container = NSPersistentContainer(name: "BusinessTracker", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}