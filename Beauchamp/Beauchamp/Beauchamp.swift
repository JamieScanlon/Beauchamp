//
//  Beauchamp.swift
//  Beauchamp
//
//  Created by Jamie Scanlon on 5/4/16.
//  Copyright © 2016 TenthLetterMade. All rights reserved.
//

import Foundation

public let BeauchampStudyChangeNotification = "com.tenthlettermade.beauchamp.BeauchampStudyChangeNotification"

public class BeauchampNotificationPayload: NSObject {
    
    public var options: Set<Option>?
    public var studySescription: String?
    
}