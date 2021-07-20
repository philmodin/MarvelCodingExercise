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
        //let marvelManager = MarvelManager()
        //marvelManager.deleteAll()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testGetCharacter() {
        let expect = expectation(description: "expect")
        let marvelManager = MarvelManager()

        marvelManager.getCharacterCount(searching: "spider") {
            marvelManager.getCharacter(for: 0) {
                if let keyedCharacterMO = marvelManager.characters[0], let characterMO = keyedCharacterMO {
                    XCTAssertEqual(characterMO.name, "Spider-dok", characterMO.name ?? "No name found")
                } else {
                    XCTFail("characterMO was nil")
                }
                expect.fulfill()
            }  
        }
              
        waitForExpectations(timeout: 5)
    }
    
    func testGetCharacterApiUnavailable() {
        let expect = expectation(description: "expect")
        let marvelManager = MarvelManager(testIsApiAvailable: false)

        marvelManager.getCharacterCount {
            marvelManager.getCharacter(for: 0) {
                if let keyedCharacterMO = marvelManager.characters[0], let characterMO = keyedCharacterMO {
                    XCTAssertEqual(characterMO.name, "3-D Man", characterMO.name ?? "No name found")
                } else {
                    XCTFail("characterMO was nil")
                }
                expect.fulfill()
            }
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
