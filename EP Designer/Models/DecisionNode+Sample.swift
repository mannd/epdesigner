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
            id: "root",
            label: "Root",
            question: "What is your favorite color?",
            branches: [
                DecisionNode(
                    id: "red",
                    label: "Red",
                    question: "Why do you like red?",
                    branches: [
                        DecisionNode(id: "red-warm", label: "Warm", result: "You like passion and energy."),
                        DecisionNode(id: "red-bold", label: "Bold", result: "You value confidence and strength.")
                    ]
                ),
                DecisionNode(
                    id: "blue",
                    label: "Blue",
                    question: "Why do you like blue?",
                    branches: [
                        DecisionNode(id: "blue-calm", label: "Calm", result: "You appreciate peace and stability."),
                        DecisionNode(id: "blue-cool", label: "Cool", result: "You value rationality and clarity.")
                    ]
                ),
                DecisionNode(
                    id: "green",
                    label: "Green",
                    question: "Why do you like green?",
                    branches: [
                        DecisionNode(id: "green-nature", label: "Nature", result: "You feel connected to the outdoors."),
                        DecisionNode(id: "green-growth", label: "Growth", result: "You value progress and renewal.")
                    ]
                )
            ]
        )
    }
}
