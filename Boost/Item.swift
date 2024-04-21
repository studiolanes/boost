//
//  Item.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
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
