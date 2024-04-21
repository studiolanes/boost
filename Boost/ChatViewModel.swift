//
//  ChatViewModel.swift
//  Boost
//
//  Created by Mike Choi on 4/21/24.
//

import OpenAI
import Combine
import SwiftUI

enum ChatState {
    case idle, streaming
}

@Observable
final class Message: NSObject, Identifiable {
    enum Role: String {
        case user, assistant, system
        
        var apiRole: ChatQuery.ChatCompletionMessageParam.Role {
            switch self {
                case .user:
                    return .user
                case .assistant:
                    return .assistant
                case .system:
                    return .system
            }
        }
    }
   
    let id: UUID
    let role: Role
    var message: String
    
    init(id: UUID, role: Role, message: String) {
        self.id = id
        self.role = role
        self.message = message
    }
}

final class ChatViewModel {
    var state: ChatState = .idle
    var history: [Message] = []
    
    let openAI = OpenAI(apiToken: "")
    var stream: AnyCancellable?
    var systemPrompt: ChatQuery.ChatCompletionMessageParam?
    
    func setup(contextualContent: String?, highlighted: String?) {
        history = []
        
        var prompt = "You are a world class agent that is great at answering my questions concisely and to the point.\n"
        
        if let contextualContent {
            prompt += "\(contextualContent)\nI am going to ask you questions about the above content. Be concise and straight to the point."
            
            if let highlighted {
                prompt += "But specifically, I am going to ask you about the following part of the content?\n\(highlighted)"
            }
        } else {
            if let highlighted {
                prompt += "\(highlighted)\nI'm going to ask you questions about the above content."
            }
            
            prompt += "Be concise and straight to the point when answering."
        }
        
        systemPrompt = .init(role: .system, content: prompt)
    }
   
    func ask(scroll: @escaping () -> ()) {
        var msgs = history.compactMap {
            ChatQuery.ChatCompletionMessageParam(role: $0.role.apiRole,
                                                 content: $0.message)
        }
        if let systemPrompt {
            msgs.insert(systemPrompt, at: 0)
        }
           
        state = .streaming
       
        let asst = Message(id: .init(), role: .assistant, message: "")
        history.append(asst)
        
        let query = ChatQuery(messages: msgs, model: .gpt4_turbo)
        stream = openAI.chatsStream(query: query)
            .sink { [weak self] completion in
                withAnimation {
                    self?.state = .idle
                }
            } receiveValue: { res in
                switch res {
                    case .success(let res):
                        asst.message += res.choices.first?.delta.content ?? ""
                        scroll()
                    case .failure(let err):
                        print(err)
                }
            }

    }
}
