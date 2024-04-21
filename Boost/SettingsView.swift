//
//  SettingsView.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts

struct ShortcutSettings: View {
    var body: some View {
        Form {
            KeyboardShortcuts.Recorder("Start contextual chat", name: .startContextualChat)
            KeyboardShortcuts.Recorder("Start chat", name: .startNormalChat)
        }
        .formStyle(.grouped)
    }
}

struct SettingRowLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 80, alignment: .trailing)
            .multilineTextAlignment(.trailing)
    }
}

struct GeneralSettings: View {
    @State var launchAtLogin = true
    @State var showMenubarIcon = true

    var body: some View {
        Form {
            Section("App") {
                Toggle("Start at login", isOn: $launchAtLogin)
                Toggle("Show icon in menu bar", isOn: $showMenubarIcon)
            }
            
            Section("Context Awareness") {
                HStack {
                    Text("Request app support")
                    
                    Spacer()
                    
                    Button {
                    } label: {
                        Text("Request")
                    }
                }
            }

            Section("Chat history") {
                HStack(spacing: 20) {
                    Button {
                        
                    } label: {
                        Text("Delete all ")
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct LLMSettings: View {
    @State var useOpenAI = true
    @AppStorage ("open_ai_key") var openAI: String = ""

    var body: some View {
        Form {
            Section("Commercial") {
                VStack {
                    Toggle("OpenAI", isOn: $useOpenAI)
                    VStack(alignment: .trailing) {
                        TextField(text: $openAI, prompt: Text("API Key")) {
                        }
                        .disabled(!useOpenAI)
                        
                        Button {
                            // TODO: check api key validity
                        } label: {
                            Text("Save")
                        }
                    }
                }
                
                HStack {
                    Text("Claude")
                    Spacer()
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .formStyle(.grouped)
    }
}

struct AboutSettings: View {
    var body: some View {
        Form {
            HStack(spacing: 20) {
                Image(systemName: "square.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Boost")
                        .font(.system(size: 22, weight: .semibold))
                    
                    if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                       let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
                        Text("Version \(version), Build \(build)")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Studiolanes LLC 2024, All Rights Reserved")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            
            Divider()
            
            HStack {
                Button {
                } label: {
                    Text("Acknowledgements")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    NSWorkspace.shared.open(URL(string: "https://studiolanes.com")!)
                } label: {
                    Text("Visit our Website")
                }
                
                Button {
                    NSWorkspace.shared.open(URL(string: "https://github.com/guard_if")!)
                } label: {
                    Text("Github")
                }
                
                Button {
                    NSWorkspace.shared.open(URL(string: "https://twitter.com/guard_if")!)
                } label: {
                    Text("Twitter")
                }
            }
            .padding()
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TabView {
            GeneralSettings()
                .tabItem {
                    Label("About", systemImage: "quote.closing")
                }
            
            LLMSettings()
                .tabItem {
                    Label("LLM", systemImage: "sparkles")
                }
            
            GeneralSettings()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            ShortcutSettings()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
        }
        .padding(20)
        .frame(width: 500, height: 400)
    }
}

#Preview {
    SettingsView()
        .frame(width: 500, height: 400)
}
