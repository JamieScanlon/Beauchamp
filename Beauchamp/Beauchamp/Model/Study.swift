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
    
    // MARK: - Properties
    
    public let description: String
    private var _options: Set<Option>
    public var options: Set<Option> {
        get {
            return _options
        }
        set {
            
            predictions = []
            var maxEncounters = 0
            for option in newValue {
                maxEncounters = max(maxEncounters, option.timesEncountered)
            }
            
            var normalizedOptions: Set<Option> = []
            for option in newValue {
                var newOption: Option
                if option.timesEncountered != maxEncounters {
                    var mutableOption = option
                    mutableOption.timesEncountered = maxEncounters
                    newOption = mutableOption
                } else {
                    newOption = option
                }
                normalizedOptions.insert(newOption)
                predictions.append(Prediction(option: newOption, confidence: calculateConfidence(newOption)))
            }
            
            _options = normalizedOptions
            
            notifyOfChange()
            
        }
    }
    public private(set) var predictions: [Prediction] = []
    
    // MARK: - Methods
    
    // MARK: Init
    
    public init(description: String, optionDescriptions: Set<String>) {
        
        var newOptions: Set<Option> = []
        for description in optionDescriptions {
            let newOption = Option(description: description)
            newOptions.insert(newOption)
        }
        self.init(description: description, options: newOptions)
        
    }
    
    public init(description: String, options: Set<Option>) {
        
        self.description = description
        self._options = options
        self.predictions = []
        var maxEncounters = 0
        for option in options {
            maxEncounters = max(maxEncounters, option.timesEncountered)
        }
        
        var normalizedOptions: Set<Option> = []
        for option in options {
            var newOption: Option
            if option.timesEncountered != maxEncounters {
                var mutableOption = option
                mutableOption.timesEncountered = maxEncounters
                newOption = mutableOption
            } else {
                newOption = option
            }
            normalizedOptions.insert(newOption)
            self.predictions.append(Prediction(option: newOption, confidence: self.calculateConfidence(newOption)))
        }
        
        self._options = normalizedOptions
        
    }
    
    // MARK: Predictions
    
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
    
    // MARK: Recording
    
    mutating public func recordOptionTaken(withDescription optionDescription: String) {
        
        if let option = options.filter({$0.description == optionDescription}).first {
            recordOptionTaken(option)
        }
        
    }
    
    // MARK: Setup
    
    public func optionWitDescription(_ optionDescription: String) -> Option? {
        
        if let option = options.filter({$0.description == optionDescription}).first {
            return option
        } else {
            return nil
        }
        
    }
    
    mutating public func addOption(withDescription optionDescription: String) {
        
        if optionWitDescription(optionDescription) == nil {
            var maxEncounters = 0
            for option in options {
                maxEncounters = max(maxEncounters, option.timesEncountered)
            }
            let newOption = Option(description: optionDescription, timesTaken: 0, timesEncountered: maxEncounters)
            options.insert(newOption)
            notifyOfChange()
        }
        
    }
    
    mutating public func setOptions(withDescriptions descriptions: Set<String>) {
        
        var newOptions: Set<Option> = []
        for description in descriptions {
            let newOption = Option(description: description)
            newOptions.insert(newOption)
        }
        options = newOptions
        
    }
    
    // MARK: Utility
    // These provide functions for manipulating the data directly but generally should not
    // be used unless there is a good reason.
    
    mutating public func recordOptionTaken(_ option: Option) {
        
        var encounters = 0
        if let anyOption = options.first {
            encounters = anyOption.timesEncountered
        }
        
        var mutableOption = option
        mutableOption.timesTaken += 1
        mutableOption.timesEncountered = encounters
        updateOption(mutableOption)
        
        recordEncounter()
        
    }
    
    mutating public func updateOption(_ option: Option) {
        
        options.remove(option)
        options.insert(option)
        
    }
    
    mutating public func recordEncounter() {
        
        incrementEncounter()
        notifyOfChange()
        
    }
    
    // MARK: - Private
    
    mutating private func incrementEncounter() {
        
        let myOptions = options
        options.removeAll()
        for option in myOptions {
            var mutableOption = option
            mutableOption.timesEncountered += 1
            updateOption(mutableOption)
        }
        
    }
    
    private func calculateConfidence( _ option:Option ) -> Double {
        
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
        let notif = Notification(name: BeauchampStudyChangeNotification, object: nil, userInfo: ["payload": notificationPayload])
        NotificationCenter.default.post(notif)
        
    }
    
}
