//
//  EP_DesignerApp.swift
//  EP Designer
//
//  Created by David Mann on 6/18/25.
//

import SwiftUI

@main
struct EP_DesignerApp: App {
    @StateObject private var commandCenter = CommandCenter()
    
    var body: some Scene {
        WindowGroup {
            ContentView(root: DecisionNode.sampleTree)
                .environmentObject(commandCenter)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                // Intentionally empty to remove "New Window" (Cmd-N)
            }
            CommandGroup(after: .newItem) {
                Button("New") {
                    commandCenter.requestNewFile()
                }
                .keyboardShortcut("n", modifiers: [.command])
                
                Button("Open…") {
                    commandCenter.requestOpenFile()
                }
                .keyboardShortcut("o", modifiers: [.command])
            }
            CommandGroup(replacing: .saveItem) {
                Button("Save") {
                    commandCenter.requestSaveFile()
                }
                .keyboardShortcut("s", modifiers: [.command])
            }
            CommandGroup(after: .saveItem) {
                Button("Save As…") {
                    commandCenter.requestSaveAsFile()
                }
                .keyboardShortcut("S", modifiers: [.command, .shift])
            }
        }
    }
}

