//
//  AppDelegate.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation
import Cocoa
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate {
    let keybindingHandler = KeybindingHandler()
    var updaterController: SPUStandardUpdaterController?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        keybindingHandler.start()
        updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
    }
}
