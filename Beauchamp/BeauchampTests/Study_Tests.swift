//
//  Study_Tests.swift
//  Beauchamp
//
//  Created by Jamie Scanlon on 5/6/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import XCTest
@testable import Beauchamp

class Study_Tests: XCTestCase {
    
    var objectUnderTest: Study!
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getMostLikelyPrediciton_one_option() {
        
        var option1 = Option(description: "Option 1")
        objectUnderTest = Study(description: "Test study 1", options: [option1])
        
        //
        // Test one option, no times encountered
        //
        
        XCTAssertTrue(objectUnderTest.options.count == 1)
        
        guard let prediction1 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction1.confidence == 0)
        XCTAssertTrue(prediction1.option == option1)
        
        //
        // Test one option, one time encountered, one time taken
        //
        
        option1.timesEncountered = 1
        option1.timesTaken = 1
        
        objectUnderTest.options.insert(option1)
        
        XCTAssertTrue(objectUnderTest.options.count == 1)
        
        guard let prediction2 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction2.confidence == 0.5)
        XCTAssertTrue(prediction2.option == option1)
        
        //
        // Test one option, one hundred times encountered, one hundred times taken
        //
        
        option1.timesEncountered = 100
        option1.timesTaken = 100
        
        objectUnderTest.options.insert(option1)
        
        XCTAssertTrue(objectUnderTest.options.count == 1)
        
        guard let prediction3 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        // Confidence should asymptotically approach 1 as taken encounters go up
        XCTAssertTrue(prediction3.confidence > 0.99)
        XCTAssertTrue(prediction3.confidence < 1)
        XCTAssertTrue(prediction3.option == option1)
        
    }
    
    func test_getMostLikelyPrediciton_two_options() {
        
        var option1 = Option(description: "Option 1")
        objectUnderTest = Study(description: "Test study 2", options: [option1])
        
        //
        // Test two options, no times encountered
        //
        
        var option2 = Option(description: "Option 2")
        option1.timesEncountered = 0
        option1.timesTaken = 0
        
        objectUnderTest.options.insert(option1)
        objectUnderTest.options.insert(option2)
        
        XCTAssertTrue(objectUnderTest.options.count == 2)
        
        guard let prediction3 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction3.confidence == 0)
        
        //
        // Test two options encountered once, option one taken once, option two not taken
        //
        
        option1.timesEncountered = 1
        option1.timesTaken = 1
        option2.timesEncountered = 1
        
        objectUnderTest.options.insert(option1)
        
        XCTAssertTrue(objectUnderTest.options.count == 2)
        
        guard let prediction4 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction4.confidence == 0.5)
        XCTAssertTrue(prediction4.option == option1)
        
    }
    
    func test_recordEncounter() {
        
        let option1 = Option(description: "Option 1")
        let option2 = Option(description: "Option 2")
        let option3 = Option(description: "Option 3")
        objectUnderTest = Study(description: "Test study 3", options: [option1, option2, option3])
        
        for option in objectUnderTest.options {
            XCTAssertTrue(option.timesEncountered == 0)
        }
        
        objectUnderTest.recordEncounter()
        
        for option in objectUnderTest.options {
            XCTAssertTrue(option.timesEncountered == 1)
        }
        
    }
    
    func test_recordOptionTaken() {
        
        let option1 = Option(description: "Option 1")
        let option2 = Option(description: "Option 2")
        objectUnderTest = Study(description: "Test study 3", options: [option1])
        
        XCTAssertTrue(objectUnderTest.options.first?.timesTaken == 0)
        XCTAssertTrue(objectUnderTest.options.first?.timesEncountered == 0)
        
        objectUnderTest.recordOptionTaken(option1)
        
        XCTAssertTrue(objectUnderTest.options.first?.timesTaken == 1)
        XCTAssertTrue(objectUnderTest.options.first?.timesEncountered == 1)
        
        objectUnderTest.recordOptionTaken(option2)
        
        XCTAssertTrue(objectUnderTest.options.count == 2)
        
        for option in objectUnderTest.options {
            if option == option2 {
                XCTAssertTrue(option.timesTaken == 1)
            }
            XCTAssertTrue(option.timesEncountered == 2)
        }
        
    }
    
}
