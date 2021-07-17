//
//  MarvelManager.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/16/21.
//

import Foundation

// respond with character data

// check with CoreData for character

// request character from Marvel

class MarvelManager: NSObject {
    
    private let marvelCharacters = MarvelCharacters()
    private let marvelRequest = MarvelRequest()
    private var reachabilityCurrent: Reachability?
    private var reachabilityPrevious: Reachability.Connection?
    
    deinit { reachabilityStop() }
}

// MARK: - Provide character data
extension MarvelManager {
    
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
