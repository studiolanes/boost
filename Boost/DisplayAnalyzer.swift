//
//  DisplayAnalyzer.swift
//  Boost
//
//  Created by Mike Choi on 5/10/24.
//

import Foundation
import Cocoa

final class DisplayAnalyzer {
    static let redactedWindowNames = Set([
        "Window Server", "Screenshot", "Camp macOS", "axAuditService", "Camp", "CleanShot X", "Dock",
    ])
    
    func getCurrentCursorPosition() -> CGPoint? {
        let event = CGEvent(source: nil)
        return event?.location
    }
    
    func screenshotOfTargetedScreen() -> CGImage? {
        let screen = NSScreen.currentPointedScreen()
        return screenshot(screen: screen)
    }
    
    func screenshot(screen: NSScreen) -> CGImage? {
        guard let identifier = screen.deviceDescription[.init("NSScreenNumber")] as? NSNumber else { return nil }
        let displayId = CGDirectDisplayID(identifier.int32Value)
        guard let screenshot = CGDisplayCreateImage(displayId) else {
            return nil
        }
       
        return screenshot
    }
}
