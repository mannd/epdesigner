//
//  DecisionNode+Sample.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import Foundation

extension DecisionNode {
    static var sampleTree: DecisionNode {
        DecisionNode(
            id: Self.rootNodeId,
            label: "Root",
            question: "What is your favorite color?",
            branches: [
                DecisionNode(
                    id: "red",
                    label: "Red",
                    question: "Why do you like red?",
                    branches: [
                        DecisionNode(id: "red-warm", label: "It's warm", result: "You like passion and energy."),
                        DecisionNode(id: "red-bold", label: "It's bold", result: "You value confidence and strength.")
                    ]
                ),
                DecisionNode(
                    id: "blue",
                    label: "Blue",
                    question: "Why do you like blue?",
                    branches: [
                        DecisionNode(id: "blue-calm", label: "It's calm", result: "You appreciate peace and stability."),
                        DecisionNode(id: "blue-cool", label: "It's cool", result: "You value rationality and clarity.")
                    ]
                ),
                DecisionNode(
                    id: "green",
                    label: "Green",
                    question: "Why do you like green?",
                    branches: [
                        DecisionNode(id: "green-nature", label: "It's like nature", result: "You feel connected to the outdoors."),
                        DecisionNode(id: "green-growth", label: "It is the color of growth", result: "You value progress and renewal.")
                    ]
                )
            ]
        )
    }
}
