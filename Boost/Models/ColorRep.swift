//
//  ColorRep.swift
//  Boost
//
//  Created by Mike Choi on 5/10/24.
//

import Foundation
import Cocoa

struct ColorRep: Codable, Hashable, Equatable {
    var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    var uiColor: NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.red = r
        self.green = g
        self.blue = b
        self.alpha = a
    }
    
    init(nsColor : NSColor) {
        let adjusted = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        adjusted.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}
