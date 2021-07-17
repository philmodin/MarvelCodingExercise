//
//  MarvelCharacters.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/17/21.
//

import CoreData
import UIKit

class MarvelCharacters: NSObject {
    
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    
    override init() {
        super.init()
        persistentContainer = makeContainer()
        context = persistentContainer.viewContext
    }
    
    typealias MarvelCharacter = MarvelResponse.Container.Character
        
    var characters: [CharacterMO] = []
        
}

// MARK: - Manipulate persistent data
extension MarvelCharacters {
    
    func fetch() {
        let request: NSFetchRequest<CharacterMO> = CharacterMO.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(CharacterMO.name), ascending: true)
        request.sortDescriptors = [sort]
        do {
            characters = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func add(new character: MarvelCharacter, with image: Data?) {
        let newCharacter = CharacterMO(context: context)
        newCharacter.id = UUID(uuidString: String(character.id ?? 0))
        newCharacter.fetched = Date()
        newCharacter.name = character.name
        newCharacter.bio = character.description
        newCharacter.modified = character.modifiedDate
        newCharacter.image = image
        if let urls = character.urls { newCharacter.urls = NSSet(array: urls) }
        saveContext()
    }
    
    func update(_ existing: CharacterMO, with updated: MarvelCharacter) {
        existing.name = updated.name
        // TODO: finish updating
    }
    
}
// MARK: - Core Data stack
extension MarvelCharacters {
    
    func makeContainer() -> NSPersistentContainer {
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

    func saveContext () {
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
