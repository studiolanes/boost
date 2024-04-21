//
//  AppleScript.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation

final class AppleScript {
    static func run(_ script: String) -> String? {
        var error: NSDictionary?
        let scriptObject = NSAppleScript(source: script)
        let output = scriptObject?.executeAndReturnError(&error)
        guard let text = output?.stringValue else {
            return nil
        }
    
        return text
    }
}
