//
//  Option.swift
//  Beauchamp
//
//  Created by Jamie Scanlon on 5/4/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import Foundation

public struct Option {
    
    public let description: String
    public var timesEncountered: Int
    public var timesTaken: Int
    public  var percentageTaken: Double {
        get {
            return Double(timesTaken)/Double(timesEncountered)
        }
    }
    
    mutating public func incrementTimesEncountered() {
        timesEncountered += 1
    }
    
    mutating public func incrementTimesTaken() {
        timesTaken += 1
    }
    
    public init( description: String ) {
        self.description = description
        timesTaken = 0
        timesEncountered = 0
    }
    
    public init( description: String, timesTaken: Int, timesEncountered: Int ) {
        self.description = description
        self.timesTaken = timesTaken
        self.timesEncountered = timesEncountered
    }
    
}

// MARK: - Equatable

extension Option: Equatable {
    
}
public func ==(lhs: Option, rhs: Option) -> Bool {
    return lhs.description == rhs.description
}

// MARK: - Hashable

extension Option: Hashable {
    public var hashValue: Int {
        get {
            return description.hashValue
        }
    }
}