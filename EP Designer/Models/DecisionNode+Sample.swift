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
            question: "What is your favorite color?",
            branches: [
                "Red": DecisionNode(
                    id: "red",
                    question: "Why do you like red?",
                    branches: [
                        "Warm": DecisionNode(id: "red-warm", result: "You like passion and energy."),
                        "Bold": DecisionNode(id: "red-bold", result: "You value confidence and strength.")
                    ]
                ),
                "Blue": DecisionNode(
                    id: "blue",
                    question: "Why do you like blue?",
                    branches: [
                        "Calm": DecisionNode(id: "blue-calm", result: "You appreciate peace and stability."),
                        "Cool": DecisionNode(id: "blue-cool", result: "You value rationality and clarity.")
                    ]
                ),
                "Green": DecisionNode(
                    id: "green",
                    question: "Why do you like green?",
                    branches: [
                        "Nature": DecisionNode(id: "green-nature", result: "You feel connected to the outdoors."),
                        "Growth": DecisionNode(id: "green-growth", result: "You value progress and renewal.")
                    ]
                )
            ]
        )
    }
}
