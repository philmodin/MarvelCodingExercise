//
//  MarvelCache.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/17/21.
//

import CoreData
import UIKit

class MarvelCache: NSObject {
    
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    override init() {
        super.init()
        persistentContainer = makeContainer()
        context = persistentContainer.viewContext
        fetch()
    }
    
    typealias MarvelCharacter = MarvelResponse.Container.Character
        
    private(set) var characters: [CharacterMO] = []
        
}

// MARK: - Manipulate persistent data
extension MarvelCache {
    
    func fetch() {
        let request: NSFetchRequest<CharacterMO> = CharacterMO.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(CharacterMO.name), ascending: true)
        request.sortDescriptors = [sort]
        do {
            characters = try context.fetch(request)
        } catch {
            characters = []
            print(error.localizedDescription)
        }
    }
    
    func fetchFirst(with id: Int64?) -> CharacterMO? {
        guard let id = id
        else { return nil }
        
        let request: NSFetchRequest<CharacterMO> = CharacterMO.fetchRequest()
        request.predicate = NSPredicate(format: "(id = %d)", id)
        var character: CharacterMO? = nil
        do {
            character = try context.fetch(request).first
        } catch {
            print(error.localizedDescription)
        }
        return character
    }
    
    func addNewCharacter(with id: Int64?, name: String?, description: String?, modified: Date?, image: Data?, urls: [MarvelCharacter.URL]?) {
        guard let id = id
        else { return }
        
        let newCharacter = CharacterMO(context: context)
        newCharacter.id = id
        newCharacter.fetched = Date()
        newCharacter.name = name
        newCharacter.bio = description
        newCharacter.modified = modified
        newCharacter.image = image
        if let urls = urls {
            for url in urls {
                if let urlString = url.url, let type = url.type {
                    let urlMO = UrlMO(context: context)
                    urlMO.url = URL(string: urlString)
                    urlMO.type = type
                    newCharacter.addToUrls(urlMO)
                }
            }
        }
        save()
    }
    
    func save() {
        saveContext()
        fetch()
    }
    
}
// MARK: - Core Data stack
extension MarvelCache {
    
    private func makeContainer() -> NSPersistentContainer {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Marvel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }

    private func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func flushContext() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Character")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
}
