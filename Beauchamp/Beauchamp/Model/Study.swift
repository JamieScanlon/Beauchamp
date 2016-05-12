//
//  Study.swift
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

public struct Study {
    
    public let description: String
    public var options: Set<Option> {
        didSet {
            
            predictions = []
            var maxEncounters = 0
            for option in options {
                predictions.append(Prediction(option: option, confidence: calculateConfidence(option)))
                maxEncounters = max(maxEncounters, option.timesEncountered)
            }
            
            for option in options {
                if option.timesEncountered != maxEncounters {
                    var mutableOption = option
                    mutableOption.timesEncountered = maxEncounters
                }
            }
            
            notifyOfChange()
            
        }
    }
    public private(set) var predictions: [Prediction] = []
    
    public init(description: String, options: Set<Option>) {
        
        self.description = description
        self.options = options
        self.predictions = []
        var maxEncounters = 0
        for option in options {
            self.predictions.append(Prediction(option: option, confidence: calculateConfidence(option)))
            maxEncounters = max(maxEncounters, option.timesEncountered)
        }
        
        for option in self.options {
            if option.timesEncountered != maxEncounters {
                var mutableOption = option
                mutableOption.timesEncountered = maxEncounters
            }
        }
        
    }
    
    public func getMostLikelyPrediciton() -> Prediction? {
        
        guard let firstPrediction = predictions.first else {
            return nil
        }
        
        return predictions.reduce(firstPrediction) {
            if $1.confidence > $0.confidence {
                return $1
            } else {
                return $0
            }
        }
        
    }
    
    mutating public func recordEncounter() {
        
        incrementEncounter()
        notifyOfChange()
        
    }
    
    mutating public func recordOptionTaken( option: Option ) {
        
        var encounters = 0
        if let anyOption = options.first {
            encounters = anyOption.timesEncountered
        }
        
        var mutableOption = option
        mutableOption.timesTaken += 1
        mutableOption.timesEncountered = encounters
        options.insert(mutableOption)
        
        recordEncounter()
        
    }
    
    // MARK: - Private
    
    mutating private func incrementEncounter() {
        
        let myOptions = options
        options.removeAll()
        for option in myOptions {
            var mutableOption = option
            mutableOption.timesEncountered += 1
            options.insert(mutableOption)
        }
        
    }
    
    private func calculateConfidence( option:Option ) -> Double {
        
        guard options.contains(option) else {
            return 0
        }
        
        if option.timesEncountered == 0 {
            return 0
        }
        
        let encounteredAsDdouble = Double(option.timesEncountered)
        let takenAsDouble = Double(option.timesTaken)
        return (takenAsDouble/encounteredAsDdouble) * (encounteredAsDdouble/(encounteredAsDdouble + 1))
        
    }
    
    private func notifyOfChange() {
        
        let notificationPayload = BeauchampNotificationPayload()
        notificationPayload.options = options
        notificationPayload.studyDescription = description
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload]))
        
    }
    
}