//
//  XcodeProxy.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation

final class XcodeProxy: AppProxyDataProvider {
    func getContextualContentText() -> String? {
        let script = """
        tell application "Xcode"
            if exists (window 1) then
                set currentFileName to name of window 1
                return currentFileName
            else
                return "No active Xcode window found."
            end if
        end tell
        """
        
        guard let tabName = AppleScript.run(script) else {
            return nil
        }
        
        if let path = tabName.split(separator: " — ").dropFirst().first(where: { $0.contains(".") }) {
            return String(path)
        } else {
            return nil
        }
    }
    
    func getContextualContentDisplayText() -> String? {
        let script = """
        tell application "Xcode"
            if exists (window 1) then
                set currentFileName to name of window 1
                return currentFileName
            else
                return "No active Xcode window found."
            end if
        end tell
        """
        
        if let projectName = AppleScript.run(script)?.split(separator: " — ").first {
            return String(projectName)
        } else {
            return nil
        }
    }
    
    func getContextualContent(with text: String?) async -> String? {
        guard let projectPath = projectPath(), let text else {
            return nil
        }
  
        let rootDir = NSString(string: projectPath).deletingLastPathComponent
        let path = executeCommand("find \(rootDir) -iname \(text)")
        return try? String(contentsOfFile: path)
    }
}

extension XcodeProxy {
    func projectPath() -> String? {
        let script = """
        tell application "Xcode"
            set currentDocument to document 1
            set currentFilePath to path of currentDocument
            return currentFilePath
        end tell
        """
        
        return AppleScript.run(script)
    }
    
    func executeCommand(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh") // or "/bin/bash"
        task.standardInput = nil

        do {
            try task.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return "Error executing command: \(error.localizedDescription)"
        }
    }
}
