//
//  BeauchampFilePersistence_Tests.swift
//  BeauchampPersistence
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
import Beauchamp
@testable import BeauchampPersistence

class BeauchampFilePersistence_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_saveDirectory() {
        
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("beauchamp")
        let objectUnderTest = BeauchampFilePersistence(saveDirectory:tempDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory!.path)
        XCTAssertTrue(objectUnderTest.saveDirectory!.path == tempDirectory.path)
        
    }
    
    func test_updates_with_notification_NEW_STUDY() {
        
        // Setup BeauchampFilePersistence
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("beauchamp")
        let objectUnderTest = BeauchampFilePersistence(saveDirectory:tempDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory!.path)
        
        // Setup Study
        let option1 = Option(description: "Option 1", timesTaken: 2, timesEncountered: 10)
        let option2 = Option(description: "Option 2", timesTaken: 6, timesEncountered: 10)
        let option3 = Option(description: "Option 3", timesTaken: 0, timesEncountered: 10)
        var study = Study(description: "Study 1", options: [option1, option2, option3])
        
        //
        // Tests
        //
        
        // Archiving a new Study
        
        // Post a notification
        let notificationPayload1 = BeauchampNotificationPayload()
        notificationPayload1.options = study.options
        notificationPayload1.studyDescription = study.description
        NotificationCenter.default.post(Notification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload1]))
        
        XCTAssertFalse(objectUnderTest.lastSaveFailed)
        var isDir: ObjCBool = false
        let filePath = tempDirectory.appendingPathComponent("study\(study.description.hashValue)", isDirectory: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath.path, isDirectory: &isDir))
        
        // Updating an archived Study
        
        study = Study(description: "Study 1", options: [option3])
        
        // Post a notification
        let notificationPayload2 = BeauchampNotificationPayload()
        notificationPayload2.options = study.options
        notificationPayload2.studyDescription = study.description
        NotificationCenter.default.post(Notification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload2]))
        
        XCTAssertFalse(objectUnderTest.lastSaveFailed)
        XCTAssertTrue(FileManager.default.fileExists(atPath: filePath.path, isDirectory: &isDir))
        
    }
    
    func test_reconstituteStudies() {
        
        // Setup BeauchampFilePersistence
        let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("beauchamp")
        let objectUnderTest = BeauchampFilePersistence(saveDirectory:tempDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory!.path)
        
        // Setup Studies
        let option1 = Option(description: "Option 1", timesTaken: 4, timesEncountered: 9)
        let option2 = Option(description: "Option 2", timesTaken: 3, timesEncountered: 9)
        let option3 = Option(description: "Option 3", timesTaken: 2, timesEncountered: 9)
        let study1 = Study(description: "Study 1", options: [option1, option2, option3])
        
        // Post a notification
        let notificationPayload1 = BeauchampNotificationPayload()
        notificationPayload1.options = study1.options
        notificationPayload1.studyDescription = study1.description
        NotificationCenter.default.post(Notification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload1]))
        
        let option4 = Option(description: "Option 4", timesTaken: 50, timesEncountered: 100)
        let option5 = Option(description: "Option 5", timesTaken: 50, timesEncountered: 100)
        let study2 = Study(description: "Study 2", options: [option4, option5])
        
        // Post a notification
        let notificationPayload2 = BeauchampNotificationPayload()
        notificationPayload2.options = study2.options
        notificationPayload2.studyDescription = study2.description
        NotificationCenter.default.post(Notification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload2]))
        
        guard let studies = objectUnderTest.reconstituteStudies() else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(studies.count == 2)
        for study in studies {
            if study.description == "Study 1" {
                XCTAssertTrue(study.options.count == 3)
            } else if study.description == "Study 2" {
                XCTAssertTrue(study.options.count == 2)
            } else {
                XCTFail()
            }
        }
        
    }
    
}
