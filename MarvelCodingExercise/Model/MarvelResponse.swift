//
//  MarvelResponse.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/16/21.
//

import Foundation

struct MarvelResponse: Decodable {
    let code: Int?
    let status: String?
    let data: Container?
    struct Container: Decodable {
        let offset: Int?
        let limit: Int?
        let total: Int?
        let count: Int?
        let results: [Character]?
        struct Character: Decodable {
            let id: Int?
            let name: String?
            let description: String?
            let modified: String?
            var modifiedDate: Date? {
                let RFC3339DateFormatter = DateFormatter()
                RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
                RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssxxxx"
                RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                if let date = modified, let formatted = RFC3339DateFormatter.date(from: date) {
                    return formatted
                } else {
                    return nil
                }
            }
            let urls: [URL]?
            struct URL: Decodable {
                let type: String?
                let url: String?
            }
            let thumbnail: Thumbnail?
            struct Thumbnail: Decodable {
                let path: String?
                let `extension`: String?
            }
        }
    }
}
