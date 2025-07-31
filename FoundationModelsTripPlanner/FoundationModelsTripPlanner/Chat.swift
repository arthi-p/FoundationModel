//
//  Chat.swift
//  FoundationModelsTripPlanner
//
//  Created by fnu ashwin on 2025-06-17.
//  Copyright © 2025 Apple. All rights reserved.
//

import SwiftUI
import FoundationModels
import NaturalLanguage

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isUser: Bool
}
@MainActor var session : LanguageModelSession?

struct ChatView: View {
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(messages) { message in
                            HStack {
                                if message.isUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue.opacity(0.7))
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding()
                }
                .onChange(of: messages.count) { _ in
                    if let last = messages.last {
                        scrollProxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
            
            Divider()
            
            HStack {
                TextField("Enter message", text: $inputText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)
                
                Button("Send") {
                    sendMessage()
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .onAppear(perform: {
            Task{
                do {
                    try await initializeLMM()

                } catch {
                    print(error)
                }
            }
        })
        
       
    }
        
    func initializeLMM() async throws{
            do {
                let tradeTool = TradeTool()
                let content = tradeTool.getReportData()
                session = LanguageModelSession{
                    "summarize this when user asks for report summary"
                    content
                }
                
                /*
                 """
                                          You are a helpful financial assistant.

                                          - When the user asks about their portfolio, stock holdings, gains/losses,history or specific stock performance, always use the `tradeTool` to fetch the relevant data.
                                          - Wait for the tool’s response before answering the user.
                                          - Your job is to interpret and summarize that data clearly for the user.
                                          - Do not guess. Only answer after using the tool.
                                          - Analyse market sentiment with reporttool and provide suggestion to user on sell or buy
                                          """

                 as well as market sentiment, research insights, and buy/sell suggestions.
                 */
            }
    }
    
    func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        messages.append(ChatMessage(text: trimmed, isUser: true))
        inputText = ""

        // Simulated server response (replace with real API call)
        Task {
            do {
                let response2 = try await session!.respond(to: trimmed)
                messages.append(ChatMessage(text: response2.content, isUser: false))
                print(response2)
            } catch {
                messages.append(ChatMessage(text: error.localizedDescription, isUser: false))
               try await initializeLMM()
                print(error)
            }
           
        }
    }
}

struct ContentView: View {
    var body: some View {
        ChatView()
    }
}

//@main
//struct ChatApp: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//    }
//}

