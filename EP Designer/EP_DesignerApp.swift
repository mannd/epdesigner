//
//  EP_DesignerApp.swift
//  EP Designer
//
//  Created by David Mann on 6/18/25.
//

import SwiftUI

@main
struct EP_DesignerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(root: DecisionNode.sampleTree)
        }
    }
}
