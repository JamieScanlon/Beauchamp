//
//  Option.swift
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
    
    public init(description: String) {
        self.description = description
        timesTaken = 0
        timesEncountered = 0
    }
    
    public init(description: String, timesTaken: Int, timesEncountered: Int) {
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
