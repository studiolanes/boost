//
//  NSScreen+Extensions.swift
//  Camp macOS
//
//  Created by Mike Choi on 2/1/24.
//

import Foundation
import Cocoa

extension NSScreen {
    static func currentPointedScreen() -> NSScreen {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        
        for screen in screens {
            if NSMouseInRect(mouseLocation, screen.frame, false) {
                return screen
            }
        }
        
        return NSScreen.main!
    }
}
