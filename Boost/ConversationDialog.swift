//
//  ContentView.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import Combine
import SwiftUI
import SwiftData
import OpenAI
import MarkdownUI
import Splash

struct ContextualConversationDialog: View {
    let dismiss: () -> ()
    @State var safari = SafariProxy()
    @State var query: String = ""
    @State var vm = ChatViewModel()
    @State var scrollPositionID: UUID?
    
    @Environment(ContextualChatModel.self) var contextVM
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            windowContent
           
            VStack(spacing: 10) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.escape, modifiers: [])
                
                Button {
                    
                } label: {
                    Image(systemName: "text.append")
                }
                .buttonStyle(.plain)
                
                Divider()
                    .frame(width: 10)
                
                SettingsLink {
                    Image(systemName: "gearshape.fill")
                }
                .buttonStyle(.plain)
            }
            .foregroundStyle(.secondary)
            .padding(.horizontal, 6)
            .padding(.vertical, 10)
            .background(RoundedRectangle(cornerRadius: 18).foregroundStyle(.ultraThinMaterial))
        }
        .onChange(of: contextVM.content, initial: true) { oldValue, newValue in
            vm.setup(contextualContent: newValue, highlighted: contextVM.highlighted)
        }
    }
    
    func sendMessage() {
        let newID = UUID()
        vm.history.append(.init(id: newID, role: .user, message: query))
        withAnimation {
            scrollPositionID = vm.history.last?.id
        }
        
        query = ""
        vm.ask { }
    }
   
    @ViewBuilder
    func contextAppHeader(_ app: NSRunningApplication, isHistoryEmpty: Bool) -> some View {
        HStack(spacing: 8) {
            if let icon = app.icon {
                let size: CGFloat = isHistoryEmpty ? 34 : 20
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: size, height: size)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                if let title = contextVM.title {
                    Text(title)
                        .font(.system(size: vm.history.isEmpty ? 12 : 10, weight: .medium))
                        .lineLimit(1)
                }
                
                if let subtitle = contextVM.subtitle, vm.history.isEmpty {
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 12))
                        .lineLimit(1)
                }
            }
           
            if contextVM.highlighted != nil {
                Spacer()
                
                Text("HIGHLIGHTED")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.yellow)
                    .padding(4)
                    .background(RoundedRectangle(cornerRadius: 4).foregroundColor(.yellow.opacity(0.2)))
            }
        }
        
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(isHistoryEmpty ? 8 : 4)
        .background(RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(Color(nsColor: .tertiarySystemFill)))
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }
    
    var windowContent: some View {
        VStack {
            let isHistoryEmpty = vm.history.isEmpty
            if let app = contextVM.app {
                contextAppHeader(app, isHistoryEmpty: isHistoryEmpty)
            }
            
            if vm.history.isEmpty, vm.state == .idle {
                Spacer()
                
                VStack(spacing: 6) {
                    Image(systemName: "bubble.fill")
                    Text("What's on your mind?")
                }
                .foregroundStyle(.tertiary)
                .padding(.vertical, 20)
                
                Spacer()
            }
            
            if vm.history.count > 0 {
                ScrollView {
                    LazyVStack {
                        ForEach(vm.history) { msg in
                            let isUser = msg.role == .user
                            HStack {
                                if isUser {
                                    Text(msg.message)
                                        .textSelection(.enabled)
                                        .font(.system(size: 14))
                                        .foregroundStyle(.white)
                                        .padding(6)
                                        .padding(.horizontal, 4)
                                        .background(RoundedRectangle(cornerRadius: 16).foregroundStyle(.blue))
                                } else {
                                    Markdown(msg.message)
                                        .textSelection(.enabled)
                                        .markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color(nsColor: .labelColor))
                                        .padding(6)
                                        .padding(.horizontal, 4)
                                        .background(RoundedRectangle(cornerRadius: 16)
                                            .foregroundStyle(Color(nsColor: .tertiarySystemFill)
                                        ))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: isUser ? .trailing : .leading)
                            .id(msg.id)
                            .contextMenu {
                                Button {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(msg.message, forType: .string)
                                } label: {
                                    Text("Copy")
                                }
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollContentBackground(.hidden)
                .scrollPosition(id: $scrollPositionID, anchor: .bottom)
            }
            
            HStack {
                TextField(text: $query, prompt: Text("Talk to GPT-4")) {
                }
                .textFieldStyle(.plain)
                .padding(6)
                .padding(.horizontal, 4)
                .background(RoundedRectangle(cornerRadius: 18).stroke(.primary.opacity(0.2), lineWidth: 0.8))
                .onSubmit {
                    withAnimation {
                        sendMessage()
                    }
                }
                
                Button {
                    withAnimation {
                        sendMessage()
                    }
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22, weight: .semibold))
                        .tint(.accentColor)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.return)
                .disabled(query.isEmpty)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(.windowBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var theme: Splash.Theme {
        // NOTE: We are ignoring the Splash theme font
        switch self.colorScheme {
            case .dark:
                return .wwdc17(withFont: .init(size: 16))
            default:
                return .sunset(withFont: .init(size: 16))
        }
    }
    
    var appPreview: some View {
        HStack(spacing: 10) {
            if let app = contextVM.app {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 34, height: 34)
                }
           
                VStack(alignment: .leading, spacing: 2) {
                    if let title = contextVM.title {
                        Text(title)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    
                    if let subtitle = contextVM.subtitle {
                        Text(subtitle)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 12))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(Color(nsColor: .tertiarySystemFill)))
        .padding(8)
    }
}

#Preview {
    ContextualConversationDialog(dismiss: {} )
        .environment(ContextualChatModel())
        .modelContainer(for: Item.self, inMemory: true)
        .background(.white)
        .padding(40)
}
