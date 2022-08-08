//
//  DataController.swift
//  virtual-tourist
//
//  Created by RhaXiel on 7/8/22.
//

import Foundation
import CoreData

class DataController{
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(_ modelName: String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContext() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil ){
        persistentContainer.loadPersistentStores{ storeDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            self.configureContext()
            completion?()
        }
    }
    
    func save() throws {
        if viewContext.hasChanges {
            print("Saving...")
            try viewContext.save()
        }
    }
    
    func autoSaveViewContext(interval: TimeInterval = 30){
        print("Autosaving...")
        
        guard interval > 0 else {
            print("Cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
    }
    
    //MARK: Fetch functions
    func fetchLocation(_ predicate: NSPredicate, sorting: NSSortDescriptor? = nil) throws -> Pin? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        request.predicate = predicate
        if let sorting = sorting {
            request.sortDescriptors = [sorting]
        }
        guard let location = (try viewContext.fetch(request) as! [Pin]).first else {
            return nil
        }
        return location
    }
    
    func fetchAllLocations() throws -> [Pin]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")
        guard let pin = try viewContext.fetch(request) as? [Pin] else {
            return nil
        }
        return pin
    }
    
    func fetchAllPhotos(_ predicate: NSPredicate? = nil, sorting: NSSortDescriptor? = nil) throws -> [Photo]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        request.predicate = predicate
        if let sorting = sorting {
            request.sortDescriptors = [sorting]
        }
        guard let allPhoto = try viewContext.fetch(request) as? [Photo] else {
            return nil
        }
        return allPhoto
    }
    
}
