//
//  Keybindings.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let startContextualChat = Self("startContextualChat")
    static let startNormalChat = Self("startNormalChat")
}

// MARK: -

final class KeybindingHandler {
    let floatingChatController = FloatingChatController()
    
    func start() {
        KeyboardShortcuts.onKeyUp(for: .startContextualChat) { [weak self] in
            self?.floatingChatController.show()
        }
        
        KeyboardShortcuts.onKeyUp(for: .startNormalChat) { [weak self] in
            self?.floatingChatController.show(context: false)
        }
    }
}
