//
//  BeauchampPersistence.swift
//  BeauchampPersistence
//
//  Created by Jamie Scanlon on 5/7/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import Foundation
import Beauchamp

// MARK: - BeauchampFilePersistence

public class BeauchampFilePersistence {
    
    public static let sharedInstance = BeauchampFilePersistence()
    public var saveDirectory: NSURL?
    public private(set) var lastSaveFailed: Bool = false
    
    convenience public init(saveDirectory: NSURL) {
        self.init()
        self.saveDirectory = saveDirectory
    }
    
    public init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BeauchampFilePersistence.handaleChangeNotification(_:)), name: BeauchampStudyChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BeauchampStudyChangeNotification, object: nil)
    }
    
    // MARK: Methods
    
    public func reconstituteStudies() -> [Study]? {
        
        guard let saveDirectory = saveDirectory,
              let directoryPath = saveDirectory.path else {
            return nil
        }
        
        var directoryContent: [String] = []
        do {
            directoryContent = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(directoryPath)
        } catch {
            return nil
        }
        
        var studies: [Study] = []
        for filename in directoryContent {
            if filename.hasPrefix("study"),
               let filePath = saveDirectory.URLByAppendingPathComponent(filename, isDirectory: false).path,
               let encodableStudy = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? EncodableStudy,
               let study = encodableStudy.study {
                studies.append(study)
            }
        }
        
        return studies
        
    }
    
    // MARK: Notification Handler
    
    @objc func handaleChangeNotification(notif:NSNotification) {
        
        guard let saveDirectory = saveDirectory else {
            return
        }
        
        guard let userInfo = notif.userInfo,
              let payload = userInfo["payload"] as? BeauchampNotificationPayload,
              let studyOptions = payload.options,
              let studyDescription = payload.studyDescription else {
                return
        }
        
        let encodableStudy = EncodableStudy(study: Study(description: studyDescription, options: studyOptions))
        let fullPath = saveDirectory.URLByAppendingPathComponent("study\(studyDescription.hashValue)", isDirectory: false)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(encodableStudy, toFile: fullPath.path!)
        if !isSuccessfulSave {
            lastSaveFailed = true
        } else {
            lastSaveFailed = false
        }
        
    }
    
}

// MARK: - BeauchampUserDefaultsPersistence

public class BeauchampUserDefaultsPersistence {
    
    public static let sharedInstance = BeauchampUserDefaultsPersistence()
    public var defaults: NSUserDefaults?
    public var defaultsKey: String?
    
    convenience public init(defaults: NSUserDefaults, key: String) {
        self.init()
        self.defaults = defaults
        self.defaultsKey = key
    }
    
    public init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BeauchampFilePersistence.handaleChangeNotification(_:)), name: BeauchampStudyChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: BeauchampStudyChangeNotification, object: nil)
    }
    
    // MARK: Methods
    
    public func reconstituteStudies() -> [Study]? {
        
        guard let defaults = defaults,
              let defaultsKey = defaultsKey else {
                return nil
        }
        
        let studyListKey = "\(defaultsKey).studyList"
        
        guard let studyListData = defaults.dataForKey(studyListKey),
              let studyList = NSKeyedUnarchiver.unarchiveObjectWithData(studyListData) as? [String] else {
            return nil
        }
        
        var studies: [Study] = []
        for studyKey in studyList {
            
            let fullStudyKey = "\(defaultsKey).\(studyKey)"
            
            if let studyData = defaults.dataForKey(fullStudyKey),
               let encodableStudy = NSKeyedUnarchiver.unarchiveObjectWithData(studyData) as? EncodableStudy,
               let study = encodableStudy.study {
                studies.append(study)
            }
            
        }
        
        return studies
        
    }
    
    // MARK: Notification Handler
    
    @objc func handaleChangeNotification(notif:NSNotification) {
        
        guard let defaults = defaults,
              let defaultsKey = defaultsKey else {
                return
        }
        
        guard let userInfo = notif.userInfo,
            let payload = userInfo["payload"] as? BeauchampNotificationPayload,
            let studyOptions = payload.options,
            let studyDescription = payload.studyDescription else {
                return
        }
        
        let encodableStudy = EncodableStudy(study: Study(description: studyDescription, options: studyOptions))
        let studyKey = "study\(studyDescription.hashValue)"
        let fullStudyKey = "\(defaultsKey).\(studyKey)"
        let studyData = NSKeyedArchiver.archivedDataWithRootObject(encodableStudy)
        defaults.setObject(studyData, forKey: fullStudyKey)
        
        let studyListKey = "\(defaultsKey).studyList"
        if let studyListData = defaults.dataForKey(studyListKey),
           let studyList = NSKeyedUnarchiver.unarchiveObjectWithData(studyListData) as? [String] {
            if !studyList.contains(studyKey) {
                var mutableStudyList = studyList
                mutableStudyList.append(studyKey)
                let newStudyListData = NSKeyedArchiver.archivedDataWithRootObject(mutableStudyList)
                defaults.setObject(newStudyListData, forKey: studyListKey)
            }
        } else {
            let newStudyList = [studyKey]
            let newStudyListData = NSKeyedArchiver.archivedDataWithRootObject(newStudyList)
            defaults.setObject(newStudyListData, forKey: studyListKey)
        }
        
    }
    
}

// MARK: - EncodableStudy

struct EncodableStudyPropertyKey {
    static let descriptionKey = "description"
    static let optionsKey = "options"
}

class EncodableStudy: NSObject, NSCoding {
    
    var study: Study?
    
    init(study:Study) {
        self.study = study
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        
        guard let description = aDecoder.decodeObjectForKey(EncodableStudyPropertyKey.descriptionKey) as? String else {
            return nil
        }
        
        guard let optionDicts = aDecoder.decodeObjectForKey(EncodableStudyPropertyKey.optionsKey) as? [[String: AnyObject]] else {
            return nil
        }
        
        var options: Set<Option> = []
        for optionDict in optionDicts {
            if let optionDescription = optionDict["description"] as? String,
               let optionsTimesTaken = optionDict["timesTaken"] as? Int,
                let optionsTimesEncountered = optionDict["timesEncountered"] as? Int {
                options.insert(Option(description: optionDescription, timesTaken: optionsTimesTaken, timesEncountered: optionsTimesEncountered))
            }
        }
        
        self.init(study: Study(description: description, options: options))
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        
        guard let study = study else {
            return
        }
        
        aCoder.encodeObject(study.description, forKey: EncodableStudyPropertyKey.descriptionKey)
        
        var options: [[String: AnyObject]] = []
        for option in study.options {
            options.append(["description": option.description, "timesTaken": option.timesTaken, "timesEncountered": option.timesEncountered])
        }
        aCoder.encodeObject(options, forKey: EncodableStudyPropertyKey.optionsKey)
        
    }
    
}
