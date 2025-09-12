//
//  MainView.swift
//  EP Designer
//
//  Created by David Mann on 6/18/25.
//

import SwiftUI


// test data
let testData: [SimpleDecisionNode] = [
    .init(question: "What is your favorite color?", branches: [:])]


struct MainView: View {
    @State var selectedNode: SimpleDecisionNode.ID?

    var body: some View {
        NavigationSplitView {
            List(selection: $selectedNode) {
            }
        } detail: { Text("Test") }
    }
}

#Preview {
    MainView()
}
