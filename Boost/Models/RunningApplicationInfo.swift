//
//  RunningApplicationInfo.swift
//  Boost
//
//  Created by Mike Choi on 5/10/24.
//

import Foundation

struct RunningApplicationInfo: Codable, Hashable {
    let kCGWindowName: String?
    let kCGWindowOwnerName: String?
    let kCGWindowIsOnscreen: Bool
    let kCGWindowAlpha: Double
    let kCGWindowBounds: WindowRect
    let kCGWindowOwnerPID: Int
    var bundleURL: URL?
    var color: ColorRep?
    
    var rect: CGRect {
        .init(x: kCGWindowBounds.X, y: kCGWindowBounds.Y, width: kCGWindowBounds.Width, height: kCGWindowBounds.Height)
    }
    
    static let unknown = RunningApplicationInfo(kCGWindowName: "UNKNOWN", kCGWindowOwnerName: "Desktop", kCGWindowIsOnscreen: true, kCGWindowAlpha: 1, kCGWindowBounds: .init(X: 0, Y: 0, Width: 0, Height: 0), kCGWindowOwnerPID: 0, bundleURL: URL(string: "unknown")!, color: .init(r: 0.95, g: 0.95, b: 0.95))
}
