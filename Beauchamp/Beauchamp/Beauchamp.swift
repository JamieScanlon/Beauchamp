//
//  Beauchamp.swift
//  Beauchamp
//
//  Created by Jamie Scanlon on 5/4/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import Foundation

let BeauchampStudyChangeNotification = "com.tenthlettermade.beauchamp.BeauchampStudyChangeNotification"

class BeauchampNotificationPayload: NSObject {
    
    var options: Set<Option>?
    var studySescription: String?
    
}