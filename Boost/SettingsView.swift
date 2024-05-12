//
//  SettingsView.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Foundation
import SwiftUI
import KeyboardShortcuts
import OpenAI
import LaunchAtLogin

struct ShortcutSettings: View {
    var body: some View {
        Form {
            Section("Shortcuts") {
                KeyboardShortcuts.Recorder("Start contextual chat", name: .startContextualChat)
                KeyboardShortcuts.Recorder("Start chat", name: .startNormalChat)
            }
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
    @AppStorage("show.menubar.icon") var showMenuBar = true

    var body: some View {
        Form {
            Section("App") {
                LaunchAtLogin.Toggle("Launch at login")
                Toggle("Show icon in menu bar", isOn: $showMenuBar)
            }
            
            Section("Support") {
                HStack {
                    Text("Contact us")
                    
                    Spacer()
                    
                    Button {
                        NSWorkspace.shared.open(URL(string: "mailto:hello@studiolanes.com")!)
                    } label: {
                        Text("Email")
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

enum APIValidateState: String {
    case needsValidation, inProgress, validated, invalid
    
    var color: Color {
        switch self {
            case .needsValidation:
                return .gray
            case .inProgress:
                return .orange
            case .validated:
                return .green
            case .invalid:
                return .red
        }
    }
    
    var description: String {
        switch self {
            case .needsValidation:
                return "API Key Required"
            case .inProgress:
                return "Checking..."
            case .validated:
                return "Operational"
            case .invalid:
                return "Invalid key"
        }
    }
}

struct LLMSettings: View {
    static let DEFAULT_SYSTEM_PROMPT = "You are a world class assistant that is great at answering my questions concisely and to the point."
    
    @State var useOpenAI = true
    
    @AppStorage ("open_ai_key_state") var openAIValidationState: APIValidateState = .needsValidation
    @AppStorage ("open_ai_key") var openAI = ""
    @AppStorage ("system_prompt") var systemPrompt = DEFAULT_SYSTEM_PROMPT

    var body: some View {
        Form {
            Section("Models") {
                VStack {
                    Toggle("OpenAI", isOn: $useOpenAI)
                    
                    VStack(alignment: .trailing) {
                        TextField(text: $openAI, prompt: Text("API Key")) {
                        }
                        .font(.system(size: 11, design: .monospaced))
                        .disabled(!useOpenAI)
                      
                        HStack {
                            HStack(alignment: .center, spacing: 8) {
                                Circle().frame(width: 6)
                                    .foregroundStyle(openAIValidationState.color)
                                
                                Text(openAIValidationState.description)
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .padding(4)
                            .padding(.horizontal, 6)
                            .background(Capsule().stroke(.tertiary.opacity(0.8), lineWidth: 1))
                            
                            Spacer()
                           
                            Button {
                                Task {
                                    await checkIntegration(key: openAI)
                                }
                            } label: {
                                Text("Save")
                            }
                            .disabled(!useOpenAI)
                        }
                    }
                }
                
                HStack {
                    Text("Claude")
                    Spacer()
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12, weight: .medium))
                }
            }
            
            Section("Prompt") {
                TextField("", text: $systemPrompt, prompt: Text("Enter system prompt"), axis: .vertical)
                    .font(.system(size: 11, design: .monospaced))
               
                HStack {
                    Spacer()
                    
                    Button {
                        systemPrompt = LLMSettings.DEFAULT_SYSTEM_PROMPT
                    } label: {
                        Text("Restore original prompt")
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
    
    func checkIntegration(key: String) async {
        withAnimation {
            openAIValidationState = .inProgress
        }
        
        let res = try? await OpenAI(apiToken: key).chats(query: .init(messages: [.system(.init(content: "just say hi"))], model: .gpt3_5Turbo))
        
        withAnimation {
            if res != nil {
                openAIValidationState = .validated
            } else {
                openAIValidationState = .invalid
            }
        }
    }
}

struct AboutSettings: View {
    var body: some View {
        Form {
            HStack(spacing: 20) {
                Image("icon")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    .shadow(color: .black.opacity(0.1), radius: 10)
                
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
                    NSWorkspace.shared.open(URL(string: "https://studiolanes.notion.site/Boost-Acknowledgements-7b58dd763d4a46d190402e346823c301?pvs=4")!)
                } label: {
                    Text("Acknowledgements")
                        .foregroundStyle(.secondary)
                        .font(.system(size: 10, weight: .semibold))
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                Button {
                    NSWorkspace.shared.open(URL(string: "https://getcampana.com/tools/chat")!)
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
                    Label("General", systemImage: "gear")
                }
            
            LLMSettings()
                .tabItem {
                    Label("LLM", systemImage: "sparkles")
                }
            
            ShortcutSettings()
                .tabItem {
                    Label("Shortcuts", systemImage: "keyboard")
                }
            
            AboutSettings()
                .tabItem {
                    Label("About", systemImage: "quote.closing")
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
