//
//  ExtensionInt.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/19/21.
//

import Foundation

extension Int {

    func toDecimalString() -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? "error"
        
    }
}
