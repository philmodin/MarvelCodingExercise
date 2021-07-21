//
//  MarvelManager.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/16/21.
//

import Foundation

typealias MarvelCharacter = MarvelResponse.Container.Character
typealias MarvelCharacterTotal = Int
typealias ResultForMarvel = Result<MarvelResponse, Error>

class MarvelManager {
    
    private let marvelCache = MarvelCache()
    private let marvelRequest = MarvelRequest()
    
    init(testIsOnline: Bool? = nil, testIsApiAvailable: Bool? = nil, testDeleteAll: Bool = false) {
        reachabilityStart()
        if let isOnline = testIsOnline { self.isOnline = isOnline }
        if let isApiAvailable = testIsApiAvailable { self.isApiAvailable = isApiAvailable }
        if testDeleteAll { deleteAll() }
    }
    deinit {
        reachabilityStop()
    }
    
    private var attributionText: String?
    private var searchQuery: String?
    private var searchPriority = 0
    
    private var reachabilityCurrent: Reachability?
    private var reachabilityPrevious: Reachability.Connection?
    
    private(set) var isApiAvailable = true
    private(set) var isOnline = false
    
    private(set) var total: MarvelCharacterTotal?
    private(set) var characters = [Int: CharacterMO?]()
    
    var attribution: String { return attributionText ?? "" }
}
// MARK: - Provide character data
extension MarvelManager {
    
    func getCharacterCount(searching: String? = nil, completed: @escaping () -> Void) {
        if let query = searching, query == searchQuery {
            return
        }
        searchPriority += 1
        let taskPriority = searchPriority
        total = nil
        characters = [:]
        
        searchQuery = searching
        
        if !isOnline || !isApiAvailable {
            getCharactersFromCache() { completed() }            
        } else {
            marvelRequest.total(searching: searchQuery) { [weak self] count, attributionText in
                guard let self = self else { return }
                guard taskPriority == self.searchPriority else { return }
                
                self.attributionText = attributionText
                if count == nil {
                    self.isApiAvailable = false
                    self.getCharactersFromCache() { completed() }
                } else {
                    self.total = count
                    completed()
                }
            }
        }
    }
    
    func getCharacter(for row: Int, completed: @escaping () -> Void) {
        let taskPriority = searchPriority
        if characters.keys.contains(row) || !isOnline || !isApiAvailable {
            completed()
        } else {
            characters.merge([row : nil]) { _, new in new }
            marvelRequest.character(searching: searchQuery, at: row) { [weak self] mChar in
                guard taskPriority == self?.searchPriority else { return }
                
                if mChar == nil { self?.isApiAvailable = false }
                if let characterMO = self?.marvelCache.fetchFirst(with: mChar?.id) {
                    self?.characters.merge([row : characterMO]) { _, new in new }
                    completed()
                } else {
                    self?.marvelRequest.image(for: mChar) { [weak self] imageData in
                        self?.createCharacterMO(from: mChar, with: imageData)
                        guard taskPriority == self?.searchPriority else { return }
                        if let characterMO = self?.marvelCache.fetchFirst(with: mChar?.id) {
                            self?.characters.merge([row : characterMO]) { _, new in new }
                        }
                        completed()
                    }
                }
            }
        }
    }
    
    func deleteAll() {
        marvelCache.flushContext()
    }
    
    private func createCharacterMO(from mChar: MarvelCharacter?, with image: Data?) {
        marvelCache.addNewCharacter(
            with: mChar?.id,
            attribution: attributionText,
            name: mChar?.name,
            description: mChar?.description,
            modified: mChar?.modifiedDate,
            image: image, urls: mChar?.urls
        )
    }
    
    private func getCharactersFromCache(completed: @escaping () -> Void) {
        marvelCache.fetch(searching: searchQuery)
        
        if marvelCache.characters.count < 1, searchQuery == nil {
            importSampleCharacter { [weak self] in
                guard let self = self
                else {
                    completed()
                    return
                }
                self.marvelCache.fetch(searching: self.searchQuery)
                self.characters = self.marvelCache.characters
                self.total = self.characters.count
                self.attributionText = self.characters.first?.value?.attribution
                completed()
            }
        } else {
            characters = marvelCache.characters
            total = characters.count
            attributionText = characters.first?.value?.attribution
            completed()
        }
    }
    
    private func importSampleCharacter(completed: @escaping () -> Void) {
        marvelRequest.sample { [weak self] mC, attributionText in
            self?.attributionText = attributionText
            self?.marvelRequest.image(for: mC) { [weak self] imageData in
                self?.createCharacterMO(from: mC, with: imageData)
                completed()
            }
        }
    }
}
// MARK: - Check internet connectivity via Reachability
extension MarvelManager {
    @objc
    private func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        if reachability.connection != reachabilityPrevious {
            switch reachability.connection {
            case .unavailable:
                if reachabilityPrevious != .unavailable {
                    reachabilityPrevious = reachability.connection
                    isOnline = false
                    // TODO: change source
                }
            case .cellular, .wifi:
                if reachabilityPrevious == .unavailable {
                    reachabilityPrevious = reachability.connection
                    isOnline = true
                    // TODO: change source
                }
            }
        }
    }
    
    private func reachabilityStart() {
        reachabilityCurrent = try? Reachability(hostname: marvelRequest.host)
        if reachabilityCurrent?.connection != .unavailable { isOnline = true }
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(_:)), name: .reachabilityChanged, object: reachabilityCurrent)
        do {
            try reachabilityCurrent?.startNotifier()
        } catch {
            print("Unable to start reachability notifier: \(error)")
        }
    }
    
    private func reachabilityStop() {
        reachabilityCurrent?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        reachabilityCurrent = nil
    }
}
