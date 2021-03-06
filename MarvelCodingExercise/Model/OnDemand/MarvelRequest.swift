//
//  MarvelRequest.swift
//  MarvelCodingExercise
//
//  Created by endOfLine on 7/16/21.
//

import CryptoKit
import Foundation

struct MarvelRequest {
    
    let host = "gateway.marvel.com"
    let endpointCharacters = "/v1/public/characters"
    let timestamp = Date().description(with: .current)
    var apiKey = ""
    var hash = ""
        
    init() {
        let publicKey = getApiKey(for: .publicKey)
        let privateKey = getApiKey(for: .privateKey)
        apiKey = publicKey
        hash = hashMD5(from: timestamp + privateKey + publicKey)
    }
}

// MARK: - Get character / image
extension MarvelRequest {
    
    func character(searching query: String?, at offset: Int, completion: @escaping (MarvelCharacter?) -> Void) {
        let url = makeURL(searching: query, offset: offset)
        
        getData(at: url) { result in
            
            switch result {
            case .failure(let error):
                print(error)
                completion(nil)
            case .success(let data) :
                decode(marvel: data) { result in
                    
                    switch result {
                    case.failure(let error):
                        print(error)
                        completion(nil)
                    case.success(let response):
                        completion(response.data?.results?.first)
                    }
                }
            }
        }
    }
    
    func image(for character: MarvelCharacter?, completion: @escaping (Data?) -> Void) {
        guard
            let path = character?.thumbnail?.path,
            let extention = character?.thumbnail?.extension,
            let url = URL(string: path + "." + extention)
        else {
            completion(nil)
            return
        }
        getData(at: url) { dataResult in
            switch dataResult {
            case.failure(_): completion(nil)
            case.success(let data): completion(data)
            }
        }
    }

    func sample(completion: @escaping (MarvelCharacter?, String?) -> Void) {
        let fileName = "CharacterSample.json"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        else { fatalError("Failed to locate \(fileName) in bundle.") }
        guard let data = try? Data(contentsOf: url)
        else { fatalError("Failed to load \(fileName) from bundle.") }
        
        decode(marvel: data) { result in
            switch result {
            case.failure(let error):
                print(error)
                completion(nil, nil)
            case.success(let response):
                completion(response.data?.results?.first, response.attributionText)
            }
        }
    }
    
    func total(searching query: String?, completion: @escaping (MarvelCharacterTotal?, String?) -> Void) {
        let url = makeURL(searching: query, offset: 0)
        
        getData(at: url) { result in
            
            switch result {
            case .failure(let error):
                print(error)
                completion(nil, nil)
            case .success(let data) :
                decode(marvel: data) { result in
                    
                    switch result {
                    case.failure(let error):
                        print(error)
                        completion(nil, nil)
                    case.success(let response):
                        completion(response.data?.total ?? 0, response.attributionText)
                    }
                }
            }
        }
    }
}

// MARK: - Make url, get data, and decode
extension MarvelRequest {
    
    private enum MarvelError: Error {
        case noData
        case server(String)
        case badURL
    }

    private func makeURL(searching query: String? = nil, offset: Int) -> URL? {
        var components = URLComponents()
            components.scheme = "https"
            components.host = host
            components.path = endpointCharacters
            components.queryItems = [
                URLQueryItem(name: "ts", value: timestamp),
                URLQueryItem(name: "apikey", value: apiKey),
                URLQueryItem(name: "hash", value: hash),
                URLQueryItem(name: "limit", value: String(1)),
                URLQueryItem(name: "offset", value: String(offset)),
            ]
        
        if let query = query {
            components.queryItems?.append(URLQueryItem(name: "nameStartsWith", value: query))
        }
        return components.url
    }
    
    private func getData(at url: URL?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = url
        else {
            completion(.failure(MarvelError.badURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data
            else {
                DispatchQueue.main.async {
                    completion(.failure(error ?? MarvelError.noData))
                }
                return
            }
            completion(.success(data))
        }.resume()
    }
    
    private func decode(marvel data: Data, completion: @escaping (ResultForMarvel) -> Void) {
        do {
            let response = try JSONDecoder().decode(MarvelResponse.self, from: data)
            if response.code != 200 {
                throw MarvelError.server(response.status ?? "Unknown error")
            }
            DispatchQueue.main.async {
                completion(.success(response))
            }
        } catch {
            DispatchQueue.main.async {
                completion(.failure(error))
            }
        }
    }

}

// MARK: - Get api keys for init
extension MarvelRequest {
    
    private enum ApiKeyType: String {
        case privateKey = "PrivateKey"
        case publicKey = "PublicKey"
    }
    
    private func getApiKey(for key: ApiKeyType) -> String {
        guard let filePath = Bundle.main.path(forResource: "Keys", ofType: "plist")
        else { fatalError(instructions()) }
        
        guard let plistFile = NSDictionary(contentsOfFile: filePath)
        else { fatalError("Could not read contents of Keys.plist") }
        
        guard let key = plistFile.object(forKey: key.rawValue) as? String
        else { fatalError("Could not read \(key) in Keys.plist") }
        
        if key.starts(with: "Paste") || key == "" || key.contains(" ") { fatalError(instructions()) }
        
        return key
    }
    
    private func instructions() -> String {
        """
        ?????? Marvel requires valid API keys
        Register for a Marvel developer account and get API keys at:
        https://developer.marvel.com/
        If you have existing keys, add them to Keys.plist\n
        """
    }
    
    private func hashMD5(from string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
