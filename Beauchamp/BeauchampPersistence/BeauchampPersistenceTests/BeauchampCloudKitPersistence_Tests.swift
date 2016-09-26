//
//  BeauchampCloudKitPersistence_Tests.swift
//  BeauchampPersistence
//
//  Created by Jamie Scanlon on 9/26/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import XCTest
import Beauchamp
@testable import BeauchampPersistence

class BeauchampCloudKitPersistence_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_key() {
        
        let ubiquitousStore = MockNSUbiquitousKeyValueStore()
        let ubiquitousStoreKey = "com.tenthlettermade.beauchamp_tests"
        let objectUnderTest = BeauchampCloudKitPersistence(ubiquitousStore: ubiquitousStore, key: ubiquitousStoreKey)
        
        XCTAssertTrue(ubiquitousStore.called_synchronize)
        
        guard let key = objectUnderTest.ubiquitousStoreKey else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(key == ubiquitousStoreKey)
        
        guard let theUbiquitousStore = objectUnderTest.ubiquitousStore else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(theUbiquitousStore === ubiquitousStore)
        
    }
    
    func test_updates_with_notification() {
        
        // Setup BeauchampUserDefaultsPersistence
        let ubiquitousStore = MockNSUbiquitousKeyValueStore()
        let ubiquitousStoreKey = "com.tenthlettermade.beauchamp_tests"
        let objectUnderTest = BeauchampCloudKitPersistence(ubiquitousStore: ubiquitousStore, key: ubiquitousStoreKey)
        XCTAssertNotNil(objectUnderTest.ubiquitousStoreKey)
        XCTAssertNotNil(objectUnderTest.ubiquitousStore)
        
        // Setup Study
        let option1 = Option(description: "Option 1", timesTaken: 2, timesEncountered: 10)
        let option2 = Option(description: "Option 2", timesTaken: 6, timesEncountered: 10)
        let option3 = Option(description: "Option 3", timesTaken: 0, timesEncountered: 10)
        var study = Study(description: "Study 1", options: [option1, option2, option3])
        
        //
        // Tests
        //
        
        // Archiving a new Study
        
        XCTAssertFalse(ubiquitousStore.called_setObject_forKey)
        XCTAssertFalse(ubiquitousStore.called_dataForKey)
        
        // Post a notification
        let notificationPayload1 = BeauchampNotificationPayload()
        notificationPayload1.options = study.options
        notificationPayload1.studyDescription = study.description
        NotificationCenter.default.post(Notification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload1]))
        
        XCTAssertTrue(ubiquitousStore.called_setObject_forKey)
        XCTAssertTrue(ubiquitousStore.called_dataForKey)
        XCTAssertNotNil(ubiquitousStore.passed_values["\(ubiquitousStoreKey).studyList"])
        XCTAssertNotNil(ubiquitousStore.passed_values["\(ubiquitousStoreKey).study\(study.description.hashValue)"])
        
        let studyListData = ubiquitousStore.passed_values["\(ubiquitousStoreKey).studyList"] as! Data
        guard let studyList = NSKeyedUnarchiver.unarchiveObject(with: studyListData) as? [String] else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(studyList.first == "study\(study.description.hashValue)")
        
        let studyData = ubiquitousStore.passed_values["\(ubiquitousStoreKey).study\(study.description.hashValue)"] as! Data
        guard let encodableStudy = NSKeyedUnarchiver.unarchiveObject(with: studyData) as? EncodableStudy else {
            XCTFail()
            return
        }
        
        guard let archivedStudy = encodableStudy.study else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(archivedStudy.description == study.description)
        XCTAssertTrue(archivedStudy.options.count == study.options.count)
        
        // Updating an archived Study
        
        study = Study(description: "Study 1", options: [option3])
        ubiquitousStore.called_setObject_forKey = false
        ubiquitousStore.called_dataForKey = false
        ubiquitousStore.passed_values = [:]
        
        // Post a notification
        let notificationPayload2 = BeauchampNotificationPayload()
        notificationPayload2.options = study.options
        notificationPayload2.studyDescription = study.description
        NotificationCenter.default.post(Notification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload2]))
        
        XCTAssertTrue(ubiquitousStore.called_setObject_forKey)
        XCTAssertTrue(ubiquitousStore.called_dataForKey)
        XCTAssertNotNil(ubiquitousStore.passed_values["\(ubiquitousStoreKey).studyList"])
        XCTAssertNotNil(ubiquitousStore.passed_values["\(ubiquitousStoreKey).study\(study.description.hashValue)"])
        
        let studyListData2 = ubiquitousStore.passed_values["\(ubiquitousStoreKey).studyList"] as! Data
        guard let studyList2 = NSKeyedUnarchiver.unarchiveObject(with: studyListData2) as? [String] else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(studyList2.first == "study\(study.description.hashValue)")
        
        let studyData2 = ubiquitousStore.passed_values["\(ubiquitousStoreKey).study\(study.description.hashValue)"] as! Data
        guard let encodableStudy2 = NSKeyedUnarchiver.unarchiveObject(with: studyData2) as? EncodableStudy else {
            XCTFail()
            return
        }
        
        guard let archivedStudy2 = encodableStudy2.study else {
            XCTFail()
            return
        }
        
        XCTAssertTrue(archivedStudy2.description == study.description)
        XCTAssertTrue(archivedStudy2.options.count == study.options.count)
        
    }
    
    func test_reconstituteStudies() {
        
        // Setup Defaults
        let ubiquitousStore = MockNSUbiquitousKeyValueStore()
        let ubiquitousStoreKey = "com.tenthlettermade.beauchamp_tests"
        
        // Setup Studies
        let option1 = Option(description: "Option 1", timesTaken: 4, timesEncountered: 9)
        let option2 = Option(description: "Option 2", timesTaken: 3, timesEncountered: 9)
        let option3 = Option(description: "Option 3", timesTaken: 2, timesEncountered: 9)
        let study1 = Study(description: "Study 1", options: [option1, option2, option3])
        
        let option4 = Option(description: "Option 4", timesTaken: 50, timesEncountered: 100)
        let option5 = Option(description: "Option 5", timesTaken: 50, timesEncountered: 100)
        let study2 = Study(description: "Study 2", options: [option4, option5])
        
        let encodableStudy1 = EncodableStudy(study: study1)
        let encodableStudy2 = EncodableStudy(study: study2)
        let study1Data = NSKeyedArchiver.archivedData(withRootObject: encodableStudy1)
        let study2Data = NSKeyedArchiver.archivedData(withRootObject: encodableStudy2)
        let studyListData = NSKeyedArchiver.archivedData(withRootObject: ["study\(study1.description.hashValue)", "study\(study2.description.hashValue)"])
        ubiquitousStore.return_dataForKeys = ["\(ubiquitousStoreKey).studyList": studyListData as Optional<AnyObject>, "\(ubiquitousStoreKey).study\(study1.description.hashValue)": study1Data as Optional<AnyObject>, "\(ubiquitousStoreKey).study\(study2.description.hashValue)": study2Data as Optional<AnyObject>]
        
        // Setup BeauchampUserDefaultsPersistence
        let objectUnderTest = BeauchampCloudKitPersistence(ubiquitousStore: ubiquitousStore, key: ubiquitousStoreKey)
        
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

fileprivate class MockNSUbiquitousKeyValueStore: NSUbiquitousKeyValueStore {
    
    var called_synchronize = false
    var called_setObject_forKey = false
    var called_dataForKey = false
    
    var passed_values: [String: Any?] = [:]
    
    var return_dataForKeys: [String: Any?] = [:]
    
    override func set(_ value: Any?, forKey defaultName: String) {
        called_setObject_forKey = true
        passed_values[defaultName] = value
    }
    
    override func data(forKey defaultName: String) -> Data? {
        called_dataForKey = true
        if let value = return_dataForKeys[defaultName] as? Data {
            return value
        }
        return nil
    }
    
    override func synchronize() -> Bool {
        called_synchronize = true
        return true
    }
    
}
