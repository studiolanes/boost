//
//  SafariProxy.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation
import SwiftUI
import WebKit

protocol AppProxyDataProvider {
    func getContextualContentText() -> String?
    func getContextualContentDisplayText() -> String?
    func getContextualContent(with text: String?) async -> String?
}

@Observable
final class SafariProxy: AppProxyDataProvider {
    func getContextualContentText() -> String? {
        getActiveURL()
    }
    
    func getContextualContentDisplayText() -> String? {
        let script = """
        tell application "Safari"
            if not (exists document 1) then
                return ""
            end if
            
            set theDocument to document 1
            set theTitle to name of theDocument
            
            return theTitle
        end tell
        """
        
        return AppleScript.run(script)
    }
    
    func getContextualContent(with text: String?) async -> String? {
        let script = """
        tell application "Safari"
            set theText to ""
            
            if not (exists document 1) then
                return "No active Safari document found."
            end if
            
            set theDocument to document 1
            set theText to text of theDocument
            
            return theText
        end tell
        """
        
        return AppleScript.run(script)
    }
    
    func getActiveURL() -> String? {
        let script = """
        tell application "Safari"
            set currentURL to URL of current tab of front window
            return currentURL
        end tell
        """
        
        return AppleScript.run(script)
    }
}



private final class HTMLContentRetriever: NSObject, WKNavigationDelegate {
    private var webView: WKWebView?
    private var completionHandler: ((Result<String, Error>) -> Void)?
    
    func getHTMLContent(from url: URL, completion: @escaping (Result<String, Error>) -> Void) {
        webView = WKWebView()
        webView?.navigationDelegate = self
        completionHandler = completion
        
        let request = URLRequest(url: url)
        webView?.load(request)
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("document.documentElement.outerHTML.toString()") { [weak self] (result, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.completionHandler?(.failure(error))
            } else if let htmlString = result as? String {
                self.completionHandler?(.success(htmlString))
            } else {
                self.completionHandler?(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve HTML content"])))
            }
            
            self.webView = nil
            self.completionHandler = nil
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        completionHandler?(.failure(error))
        self.webView = nil
        self.completionHandler = nil
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        completionHandler?(.failure(error))
        self.webView = nil
        self.completionHandler = nil
    }
}

