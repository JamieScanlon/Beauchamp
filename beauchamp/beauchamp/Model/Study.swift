//
//  Study.swift
//  beauchamp
//
//  Created by Jamie Scanlon on 5/4/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import Foundation

struct Study {
    
    let description: String
    var options: Set<Option> {
        didSet {
            predictions = []
            for option in options {
                predictions.append(Prediction(option: option, confidence: calculateConfidence(option)))
            }
        }
    }
    private(set) var predictions: [Prediction] = []
    
    init(description: String, options: Set<Option>) {
        self.description = description
        self.options = options
        self.predictions = []
        for option in options {
            predictions.append(Prediction(option: option, confidence: calculateConfidence(option)))
        }
    }
    
    func getMostLikelyPrediciton() -> Prediction? {
        
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
    
    private func calculateConfidence( option:Option ) -> Double {
        
        guard options.contains(option) else {
            return 0
        }
        
        if option.timesEncountered == 0 {
            return 0
        }
        
        return Double(option.timesTaken)/Double(option.timesEncountered)
        
    }
    
}