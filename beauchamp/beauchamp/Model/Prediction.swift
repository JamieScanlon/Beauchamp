//
//  Prediction.swift
//  beauchamp
//
//  Created by Jamie Scanlon on 5/4/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import Foundation

struct Prediction {
    
    let option: Option
    /**
     * a number between 0 and 1 where 1 represents 100% confidence in this prediction
     * and 0 represents a blind guess.
     */
    let confidence: Double
    
}