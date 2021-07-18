//
//  MCETests.swift
//  MCETests
//
//  Created by endOfLine on 7/16/21.
//
@testable
import MarvelCodingExercise
import XCTest

class MCETests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let marvelManager = MarvelManager()
        marvelManager.marvelCache.flushContext()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testCharacterDecoder() {
        let fileName = "CharacterSample.json"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        else { fatalError("Failed to locate \(fileName) in bundle.") }
        guard let data = try? Data(contentsOf: url)
        else { fatalError("Failed to load \(fileName) from bundle.") }
                
        let expect = expectation(description: "expect")
        let marvelManager = MarvelManager()
        
        marvelManager.marvelRequest.decode(marvel: data) { marvelResult in
            switch marvelResult {
            case.failure(let error): XCTFail(error.localizedDescription)
            case.success(let marvel):
                guard let character = marvel.data?.results?.first
                else {
                    XCTFail("mCharacter was nil")
                    return
                }
                marvelManager.createCharacterMO(from: character)
                if let characterMO = marvelManager.marvelCache.fetchFirst(with: character.id) {
                    XCTAssertEqual(characterMO.name, "3-D Man", characterMO.name ?? "No name found")
                } else {
                    XCTFail("characterMO was nil")
                }
                
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 5)
    }
    
    func testFetchCharacter() {
        let expect = expectation(description: "expect")
        let marvelManager = MarvelManager()

        marvelManager.character(for: "Spider", on: 0) { characterMO in
            if let characterMO = characterMO {
                XCTAssertEqual(characterMO.name, "Spider-dok", characterMO.name ?? "No name found")
            } else {
                XCTFail("characterMO was nil")
            }
            expect.fulfill()
        }
        waitForExpectations(timeout: 5)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
