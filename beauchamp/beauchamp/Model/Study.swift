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
    var options: [Option] {
        didSet {
            predictions = []
            for option in options {
                predictions.append(Prediction(option: option, confidence: calculateConfidence(option)))
            }
        }
    }
    private(set) var predictions: [Prediction] = []
    
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
        
        guard options.count > 0 else {
            return 0.0
        }
    
        var totalEncounters = 0
        for option in options {
            totalEncounters += option.timesEncountered
        }
        
        let normalizedEncounters = Double(totalEncounters)/Double(options.count)
        
        return Double(option.timesTaken)/normalizedEncounters
        
    }
    
}