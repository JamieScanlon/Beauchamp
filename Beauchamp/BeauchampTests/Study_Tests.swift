//
//  Study_Tests.swift
//  Beauchamp
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 JamieScanlon
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
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
    
    func test_options() {
        
        objectUnderTest = Study(description: "Study description", options: [])
        
        let option1 = Option(description: "Option 1", timesTaken: 1, timesEncountered: 3)
        let option2 = Option(description: "Option 2", timesTaken: 2, timesEncountered: 2)
        let option3 = Option(description: "Option 3", timesTaken: 3, timesEncountered: 1)
        let options1: Set<Option> = [option1, option2, option3]
        
        var called_notification = false
        NotificationCenter.default.addObserver(forName: BeauchampStudyChangeNotification, object: nil, queue: nil) { (notif) in
            called_notification = true
        }
        
        objectUnderTest.options = options1
        
        XCTAssertTrue(called_notification)
        
        for option in objectUnderTest.options {
            XCTAssertTrue(option.timesEncountered == 3)
        }
        
        guard let prediction1 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction1.option.description == option3.description)
        XCTAssertTrue(prediction1.confidence == 0.75)
        
        let option4 = Option(description: "Option 4", timesTaken: 4, timesEncountered: 6)
        let option5 = Option(description: "Option 5", timesTaken: 5, timesEncountered: 5)
        let option6 = Option(description: "Option 6", timesTaken: 6, timesEncountered: 4)
        let options2: Set<Option> = [option4, option5, option6]
        
        objectUnderTest.options = options2
        
        XCTAssertTrue(objectUnderTest.options.count == 3)
        for option in objectUnderTest.options {
            XCTAssertTrue(option.timesEncountered == 6)
        }
        
        guard let prediction2 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction2.option.description == option6.description)
        XCTAssertTrue(prediction2.confidence > 0.85) // ~ 0.8571...
        
    }
    
    func test_init_description_optionDescriptions() {
        
        objectUnderTest = Study(description: "My Description", optionDescriptions: ["description 1", "description 2", "description 3"])
        
        XCTAssertTrue(objectUnderTest.description == "My Description")
        XCTAssertTrue(objectUnderTest.options.count == 3)
        for option in objectUnderTest.options {
            XCTAssertTrue(option.timesEncountered == 0)
            XCTAssertTrue(option.timesTaken == 0)
        }
        
    }
    
    func test_init_description_options() {
        
        let option1 = Option(description: "Option 1", timesTaken: 1, timesEncountered: 3)
        let option2 = Option(description: "Option 2", timesTaken: 2, timesEncountered: 2)
        let option3 = Option(description: "Option 3", timesTaken: 3, timesEncountered: 1)
        objectUnderTest = Study(description: "My Description", options: [option1, option2, option3])
        
        XCTAssertTrue(objectUnderTest.description == "My Description")
        XCTAssertTrue(objectUnderTest.options.count == 3)
        for option in objectUnderTest.options {
            XCTAssertTrue(option.timesEncountered == 3)
        }
        
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
        
        objectUnderTest.updateOption(option1)
        
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
        
        objectUnderTest.updateOption(option1)
        
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
        
        objectUnderTest.updateOption(option1)
        objectUnderTest.updateOption(option2)
        
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
        
        objectUnderTest.updateOption(option1)
        
        XCTAssertTrue(objectUnderTest.options.count == 2)
        
        guard let prediction4 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction4.confidence == 0.5)
        XCTAssertTrue(prediction4.option == option1)
        
    }
    
    func test_recordOptionTaken_withDescription() {
        
        objectUnderTest = Study(description: "My Description", optionDescriptions: ["description 1", "description 2", "description 3"])
        objectUnderTest.recordOptionTaken(withDescription: "description 2")
        
        guard let prediction = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction.option.description == "description 2")
        XCTAssertTrue(prediction.option.timesTaken == 1)
        
    }
    
    func test_optionWitDescription() {
        
        objectUnderTest = Study(description: "My Description", optionDescriptions: ["description 1", "description 2", "description 3"])
        
        guard let option = objectUnderTest.optionWitDescription("description 3") else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(option.description == "description 3")
        XCTAssertTrue(option.timesTaken == 0)
        XCTAssertTrue(option.timesEncountered == 0)
        
    }
    
    func test_addOption_withDescription() {
        
        objectUnderTest = Study(description: "My Description", optionDescriptions: ["description 1", "description 2"])
        
        XCTAssertTrue(objectUnderTest.options.count == 2)
        
        objectUnderTest.addOption(withDescription: "description 3")
        
        XCTAssertTrue(objectUnderTest.options.count == 3)
        
        objectUnderTest.addOption(withDescription: "description 1")
        
        XCTAssertTrue(objectUnderTest.options.count == 3)
        
    }
    
    func test_setOptions_withDescriptions() {
        
        objectUnderTest = Study(description: "My Description", optionDescriptions: [])
        
        XCTAssertTrue(objectUnderTest.options.count == 0)
        
        objectUnderTest.setOptions(withDescriptions: ["description 1", "description 2", "description 3"])
        
        XCTAssertTrue(objectUnderTest.options.count == 3)
        
        objectUnderTest.setOptions(withDescriptions: ["description A", "description 1"])
        
        XCTAssertTrue(objectUnderTest.options.count == 2)
        
    }
    
    func test_recordTakenOprion() {
        
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
    
    func test_updateOption() {
        
        objectUnderTest = Study(description: "My Description", optionDescriptions: ["description 1", "description 2", "description 3"])
        
        XCTAssertTrue(objectUnderTest.options.count == 3)
        
        objectUnderTest.updateOption(Option(description: "description 2", timesTaken: 1, timesEncountered: 2))
        
        XCTAssertTrue(objectUnderTest.options.count == 3)
        guard let prediction1 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction1.option.description == "description 2")
        XCTAssertTrue(prediction1.option.timesTaken == 1)
        
        objectUnderTest.updateOption(Option(description: "description A", timesTaken: 2, timesEncountered: 2))
        
        XCTAssertTrue(objectUnderTest.options.count == 4)
        guard let prediction2 = objectUnderTest.getMostLikelyPrediciton() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(prediction2.option.description == "description A")
        XCTAssertTrue(prediction2.option.timesTaken == 2)
        
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
    
}
