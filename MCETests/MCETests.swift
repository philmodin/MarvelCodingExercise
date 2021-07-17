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
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    func testCharacterDecoder() throws {
        let fileName = "CharacterSample.json"
        guard let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        else { fatalError("Failed to locate \(fileName) in bundle.") }
        guard let data = try? Data(contentsOf: url)
        else { fatalError("Failed to load \(fileName) from bundle.") }
        
        let marvelRequest = MarvelRequest()
        let expect = expectation(description: "expect")
        marvelRequest.convert(data) { result in
            switch result {
            case.failure(let error):
                XCTFail(error.localizedDescription)
                expect.fulfill()
            case.success(let response):
                XCTAssertNotNil(response.data?.results?.first?.name)
                expect.fulfill()
            }
        }
        waitForExpectations(timeout: 5)
    }
    
    func testFetchCharacter() {
        let expect = expectation(description: "expect")
        let marvelRequest = MarvelRequest()
        marvelRequest.character { result in
            switch result {
            case.failure(let error):
                XCTFail(error.localizedDescription)
                expect.fulfill()
            case.success(let character):
                XCTAssertNotNil(character!.name)
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
