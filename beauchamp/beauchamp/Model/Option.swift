//
//  Option.swift
//  beauchamp
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
    
    init( aDescription: String ) {
        description = aDescription
        timesTaken = 0
        timesEncountered = 0
    }
    
    init( aDescription: String, theTimesTaken: Int, theTimesEncountered: Int ) {
        description = aDescription
        timesTaken = theTimesTaken
        timesEncountered = theTimesEncountered
    }
    
}