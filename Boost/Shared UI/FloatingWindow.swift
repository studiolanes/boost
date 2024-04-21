//
//  FloatingPanel.swift
//  Camp
//
//  Created by Mike Choi on 1/27/24.
//

import Foundation
import SwiftUI

class FloatingPanel: NSPanel, NSPopoverDelegate {
    let hideOnOutsideClick: Bool
    
    init(contentRect: NSRect, movable: Bool, hideOnOutsideClick: Bool, resizable: Bool = true) {
        self.hideOnOutsideClick = hideOnOutsideClick
        
        super.init(contentRect: contentRect, styleMask: [.nonactivatingPanel, .borderless, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        if resizable {
            styleMask.insert(.resizable)
        }

        isFloatingPanel = true
        if !resizable {
            level = .modalPanel
        }
        
        // Allow the pannel to appear in a fullscreen space
        collectionBehavior.insert(.fullScreenAuxiliary)
        
        // While we may set a title for the window, don't show it
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        backgroundColor = .clear
        
        animationBehavior = .utilityWindow
        
        // Keep the panel around after closing since I expect the user to open/close it often
        isReleasedWhenClosed = false
        
        // Hide the traffic icons (standard close, minimize, maximize buttons)
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
    }
   
    /// Close automatically when out of focus, e.g. outside click
    override func resignMain() {
        super.resignMain()
       
        if hideOnOutsideClick {
            close()
        }
    }
    
    override var canBecomeKey: Bool {
        true
    }
    
    override var canBecomeMain: Bool {
        true
    }
    
    override var acceptsFirstResponder: Bool {
        true
    }
    
    public func positionCenter() {
        if let screenSize = screen?.visibleFrame.size {
            self.setFrameOrigin(NSPoint(x: (screenSize.width-frame.size.width)/2, y: (screenSize.height-frame.size.height)/2))
        }
    }
    
    public func setCenterFrame(width: Int, height: Int) {
        if let screenSize = screen?.visibleFrame.size {
            let x = (screenSize.width-frame.size.width)/2
            let y = (screenSize.height-frame.size.height)/2
            self.setFrame(NSRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height)), display: true)
        }
    }
}

class FloatingWindow: NSWindow, NSPopoverDelegate {
    
    let closeWhenResignMain: Bool
    
    init(contentRect: NSRect, closeWhenResignMain: Bool = false) {
        self.closeWhenResignMain = closeWhenResignMain
        super.init(contentRect: contentRect, styleMask: [.titled, .closable, .fullSizeContentView], backing: .buffered, defer: false)
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        isReleasedWhenClosed = true
    }
   
//    override func resignMain() {
//        super.resignMain()
//        
//        if closeWhenResignMain {
//            close()
//        }
//    }
    
    override var acceptsFirstResponder: Bool {
        true
    }
    
    override var canBecomeKey: Bool {
        true
    }
    
    override var canBecomeMain: Bool {
        true
    }
}
