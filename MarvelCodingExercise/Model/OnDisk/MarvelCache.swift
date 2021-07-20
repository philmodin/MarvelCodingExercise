//
//  MarvelCache.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/17/21.
//

import CoreData
import UIKit

class MarvelCache {
    private let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    private let persistentContainer: NSPersistentContainer!
    private let context: NSManagedObjectContext!
    
    init() {
        persistentContainer = appDelegate.persistentContainer
        context = persistentContainer.viewContext
        //fetch()
    }
            
    private(set) var characters = [Int: CharacterMO]()
        
}

// MARK: - Manipulate persistent data
extension MarvelCache {
    
    func fetch(searching: String?) {
        let request: NSFetchRequest<CharacterMO> = CharacterMO.fetchRequest()
        let sort = NSSortDescriptor(key: #keyPath(CharacterMO.name), ascending: true)
        request.sortDescriptors = [sort]
        if let query = searching {
            request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
        }
        do {
            let array = try context.fetch(request)
            characters = Dictionary(uniqueKeysWithValues: array.enumerated().map{ ($0,$1) })
        } catch {
            characters = [:]
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
    
    func addNewCharacter(with id: Int64?, attribution: String?, name: String?, description: String?, modified: Date?, image: Data?, urls: [MarvelCharacter.URL]?) {
        guard let id = id
        else { return }
        
        let newCharacter = CharacterMO(context: context)
        newCharacter.id = id
        newCharacter.attribution = attribution
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
    }
    
}
// MARK: - Core Data stack
extension MarvelCache {

    private func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
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
