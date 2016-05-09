//
//  BeauchampFilePersistence_Tests.swift
//  BeauchampPersistence
//
//  Created by Jamie Scanlon on 5/9/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
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
        
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("beauchamp")
        let objectUnderTest = BeauchampFilePersistence(saveDirectory:tempDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory)
        XCTAssertNotNil(objectUnderTest.saveDirectory!.path)
        XCTAssertTrue(objectUnderTest.saveDirectory!.path! == tempDirectory.path!)
        
    }
    
    func test_updates_with_notification_NEW_STUDY() {
        
        // Setup BeauchampFilePersistence
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("beauchamp")
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
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload1]))
        
        XCTAssertFalse(objectUnderTest.lastSaveFailed)
        var isDir: ObjCBool = false
        let filePath = tempDirectory.URLByAppendingPathComponent("study\(study.description.hashValue)", isDirectory: false)
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(filePath.path!, isDirectory: &isDir))
        
        // Updating an archived Study
        
        study = Study(description: "Study 1", options: [option3])
        
        // Post a notification
        let notificationPayload2 = BeauchampNotificationPayload()
        notificationPayload2.options = study.options
        notificationPayload2.studyDescription = study.description
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload2]))
        
        XCTAssertFalse(objectUnderTest.lastSaveFailed)
        XCTAssertTrue(NSFileManager.defaultManager().fileExistsAtPath(filePath.path!, isDirectory: &isDir))
        
    }
    
    func test_reconstituteStudies() {
        
        // Setup BeauchampFilePersistence
        let tempDirectory = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent("beauchamp")
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
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload1]))
        
        let option4 = Option(description: "Option 4", timesTaken: 50, timesEncountered: 100)
        let option5 = Option(description: "Option 5", timesTaken: 50, timesEncountered: 100)
        let study2 = Study(description: "Study 2", options: [option4, option5])
        
        // Post a notification
        let notificationPayload2 = BeauchampNotificationPayload()
        notificationPayload2.options = study2.options
        notificationPayload2.studyDescription = study2.description
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload2]))
        
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
