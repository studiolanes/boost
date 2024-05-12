//
//  BoostApp.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import SwiftUI
import SwiftData

@main
struct BoostApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @AppStorage("show.menubar.icon") var showMenuBar = true
    @State var isInserted = true

    var body: some Scene {
        MenuBarExtra(isInserted: $isInserted) {
            Button("Open Boost") {
                appDelegate.keybindingHandler.floatingChatController.show(context: false)
            }
            
            Divider()
            
            SettingsLink(label: {
                Text("Open Settings...")
            })
            
            Link("Follow @studiolanes", destination: URL(string: "https://x.com/studiolanes")!)
            
            Button("Quit Boost") {
                exit(0)
            }
            .keyboardShortcut("q")
        } label: {
            Image("menubar")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 12)
        }
        
        Settings {
            SettingsView()
        }
    }
}
