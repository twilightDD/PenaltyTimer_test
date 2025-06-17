//
//  Item.swift
//  PenaltyTimer_test
//
//  Created by Peter Hauke on 17.06.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
