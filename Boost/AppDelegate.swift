//
//  AppDelegate.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation
import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    let keybindingHandler = KeybindingHandler()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        keybindingHandler.start()
    }
}

