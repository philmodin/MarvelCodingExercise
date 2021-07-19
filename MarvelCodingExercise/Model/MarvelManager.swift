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
    
    init() {
        reachabilityStart()
    }
    deinit {
        reachabilityStop()
    }
    
    private var searchQuery: String?
    private var searchPriority = 0
    
    private var reachabilityCurrent: Reachability?
    private var reachabilityPrevious: Reachability.Connection?
    
    private(set) var total: MarvelCharacterTotal?
    private(set) var characters = [Int: CharacterMO]()
        
}
// MARK: - Provide character data
extension MarvelManager {
    
    func getCharacterCount(searching: String? = nil, completed: @escaping () -> Void) {
        total = nil
        characters = [:]
        
        searchQuery = searching
        searchPriority += 1
        
        marvelRequest.total(searching: searchQuery) { [weak self] count in
            self?.total = count
            completed()
        }
    }
    
    func getCharacter(for row: Int, completed: @escaping () -> Void) {
        if characters[row] != nil {
            completed()
        } else {
            marvelRequest.character(searching: searchQuery, at: row) { [weak self] mChar  in
                if let characterMO = self?.marvelCache.fetchFirst(with: mChar?.id) {
                    self?.characters.merge([row : characterMO]) { _, new in new }
                    completed()
                } else {
                    self?.marvelRequest.image(for: mChar) { [weak self] imageData in
                        self?.createCharacterMO(from: mChar, with: imageData)
                        if let characterMO = self?.marvelCache.fetchFirst(with: mChar?.id) {
                            self?.characters.merge([row : characterMO]) { _, new in new }
                            completed()
                        } else {
                            completed()
                        }
                    }
                }
            }
        }
    }
    
    func deleteAll() {
        marvelCache.flushContext()
    }
    
    private func createCharacterMO(from mChar: MarvelCharacter?, with image: Data? = nil) {
        marvelCache.addNewCharacter(
            with: mChar?.id,
            name: mChar?.name,
            description: mChar?.description,
            modified: mChar?.modifiedDate,
            image: image, urls: mChar?.urls
        )
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
                    // TODO: change source
                }
            case .cellular, .wifi:
                if reachabilityPrevious == .unavailable {
                    reachabilityPrevious = reachability.connection
                    // TODO: change source
                }
            }
        }
    }
    
    private func reachabilityStart() {
        reachabilityCurrent = try? Reachability(hostname: marvelRequest.host)
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
