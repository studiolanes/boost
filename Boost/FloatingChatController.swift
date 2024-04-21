//
//  FloatingChatController.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Combine
import Cocoa
import SwiftUI
import Foundation

final class ContextualAppFactory {
    let table: [String: AppProxyDataProvider] = [
        "com.apple.Safari": SafariProxy(),
        "com.apple.dt.Xcode": XcodeProxy()
    ]
}

@Observable
final class ContextualChatModel {
    var app: NSRunningApplication?
    var appInfo: RunningApplicationInfo?
    
    var title: String?
    var subtitle: String?
    var content: String?
    var highlighted: String?
    let displayAnalyzer = DisplayAnalyzer()
    
    func getMainScreenshotTargetApplication() {
        guard let cursor = displayAnalyzer.getCurrentCursorPosition() else {
            return
        }
        
        let decoder = JSONDecoder()
        guard let info = CGWindowListCopyWindowInfo([.optionOnScreenAboveWindow], kCGNullWindowID) as? [[String: Any]] else {
            return
        }
        
        guard let json = try? JSONSerialization.data(withJSONObject: info as Any),
              let apps = try? decoder.decode([RunningApplicationInfo].self, from: json) else {
            return
        }
        
        // Remove Window Server and invisible screens
        let visible = apps.filter {
            $0.kCGWindowIsOnscreen && $0.kCGWindowAlpha > 0 && (!DisplayAnalyzer.redactedWindowNames.contains($0.kCGWindowOwnerName ?? "---")) && $0.kCGWindowOwnerName != nil
        }
        
        let cands = visible.filter {
            $0.rect.contains(cursor)
        }
       
        guard var res = cands.first else {
            return
        }
        
        let matchingApp = NSWorkspace.shared.runningApplications.first { $0.processIdentifier == res.kCGWindowOwnerPID }
        res.bundleURL = matchingApp?.bundleURL
        app = matchingApp
    }
    
    func reset() {
        title = nil
        subtitle = nil
        content = nil
    }
}

final class FloatingChatController {
    lazy var panel: FloatingPanel = {
        let screenRect = NSScreen.currentPointedScreen().visibleFrame
        let p = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: screenRect.width, height: 325), movable: true, hideOnOutsideClick: false)
        p.contentView = NSHostingView(rootView: ContextualConversationDialog { [weak self] in self?.panel.close() }
            .environment(contextualVM)
            .ignoresSafeArea())
        
        p.level = .popUpMenu
        p.titleVisibility = .hidden
        p.standardWindowButton(.closeButton)?.isHidden = true
        p.standardWindowButton(.miniaturizeButton)?.isHidden = true
        p.standardWindowButton(.zoomButton)?.isHidden = true
        return p
    }()
    
    let contextualVM = ContextualChatModel()
    let proxyFactory = ContextualAppFactory()
    
    func show(context: Bool = true) {
        if panel.isVisible {
            panel.close()
            print("CLOSING")
            return
        }
        print("SHOWING")
        
        let selectedText = getSelectedText()
        print(selectedText)
        contextualVM.highlighted = selectedText
        
        NSApp.activate(ignoringOtherApps: true)
        panel.setContentSize(.init(width: 340, height: 240))
        
        let mouseLocation = NSEvent.mouseLocation
        
        panel.setFrameOrigin(mouseLocation)
        panel.makeKeyAndOrderFront(self)
        panel.becomeFirstResponder()
        
        if !context {
            return
        }
        
        contextualVM.reset()
        contextualVM.getMainScreenshotTargetApplication()
        
        guard let app = contextualVM.app,
            let bundleID = app.bundleIdentifier else {
            return
        }
        
        let proxy = proxyFactory.table[bundleID]
        
        Task {
            if let proxy {
                let text = proxy.getContextualContentText()
                
                withAnimation {
                    contextualVM.title = proxy.getContextualContentDisplayText() ?? contextualVM.app?.localizedName
                    contextualVM.subtitle = text
                }
                
                let content = await proxy.getContextualContent(with: text)
                contextualVM.content = content
            } else {
                contextualVM.title = app.localizedName ?? contextualVM.appInfo?.kCGWindowOwnerName ?? "Application"
            }
        }
    }
}

extension FloatingChatController {
    func getSelectedText() -> String? {
        let systemWideElement = AXUIElementCreateSystemWide()

          var selectedTextValue: AnyObject?
          let errorCode = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &selectedTextValue)
          
          if errorCode == .success {
              let selectedTextElement = selectedTextValue as! AXUIElement
              var selectedText: AnyObject?
              let textErrorCode = AXUIElementCopyAttributeValue(selectedTextElement, kAXSelectedTextAttribute as CFString, &selectedText)
              
              if textErrorCode == .success, let selectedTextString = selectedText as? String {
                  return selectedTextString
              } else {
                  return nil
              }
          } else {
              return nil
          }
    }
}
