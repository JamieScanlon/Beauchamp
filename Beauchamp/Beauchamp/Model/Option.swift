//
//  Option.swift
//  Beauchamp
//
//  Created by Jamie Scanlon on 5/4/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import Foundation

struct Option {
    
    let description: String
    var timesEncountered: Int
    var timesTaken: Int
    var percentageTaken: Double {
        get {
            return Double(timesTaken)/Double(timesEncountered)
        }
    }
    
    mutating func incrementTimesEncountered() {
        timesEncountered += 1
    }
    
    mutating func incrementTimesTaken() {
        timesTaken += 1
    }
    
    init( description: String ) {
        self.description = description
        timesTaken = 0
        timesEncountered = 0
    }
    
    init( description: String, timesTaken: Int, timesEncountered: Int ) {
        self.description = description
        self.timesTaken = timesTaken
        self.timesEncountered = timesEncountered
    }
    
}

// MARK: - Equatable

extension Option: Equatable {
    
}
func ==(lhs: Option, rhs: Option) -> Bool {
    return lhs.description == rhs.description
}

// MARK: - Hashable

extension Option: Hashable {
    var hashValue: Int {
        get {
            return description.hashValue
        }
    }
}