//
//  MarvelManager.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/16/21.
//

import Foundation

class MarvelManager: NSObject {
    
    let marvelCache = MarvelCache()
    let marvelRequest = MarvelRequest()
    
    private var reachabilityCurrent: Reachability?
    private var reachabilityPrevious: Reachability.Connection?
    
    typealias MarvelCharacter = MarvelResponse.Container.Character

    override init() {
        super.init()
        reachabilityStart()
    }
    deinit { reachabilityStop() }
}

// MARK: - Provide character data
extension MarvelManager {

    func character(for query: String? = nil, on row: Int, completion: @escaping (CharacterMO?) -> Void) {
        
        if reachabilityCurrent?.connection == .unavailable {
            completion(marvelCache.characters[row])
        } else {
            marvelRequest.character(searching: query, at: row) { [weak self] mChar in
                if let charMO = self?.marvelCache.fetchFirst(with: mChar?.id) {
                    completion(charMO)
                } else {
                    self?.marvelRequest.image(for: mChar) { [weak self] imageData in
                        self?.createCharacterMO(from: mChar, with: imageData)
                        completion(self?.marvelCache.fetchFirst(with: mChar?.id))
                    }
                }
            }
        }
    }
    
    func createCharacterMO(from mChar: MarvelCharacter?, with image: Data? = nil) {
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
