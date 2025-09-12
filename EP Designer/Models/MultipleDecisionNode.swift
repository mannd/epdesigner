//
//  MultipleDecisionNode.swift
//  EP Designer
//
//  Created by David Mann on 6/22/25.
//

import Foundation

struct SimpleDecisionNode: Identifiable, Hashable {
    let id = UUID()
    var question: String?
    var branches: [String: SimpleDecisionNode]?
}

//struct DecisionNode: Codable, Identifiable {
//    let id: String?
//    var question: String?  // e.g "What is your favorite color"?
//    var branches: [String: DecisionNode]? // e.g. "Red": (Why do you like red), etc.
//    var result: String?
//
//    var note: String? // optional additional info such as "Choose red, blue, or green."
//    var tag: String? // optional other info not presented to user
//
//    var isLeaf: Bool { result != nil }
//
//    static let rootNodeId: String = "node-root" // root node ID = Self.rootNodeId
//}

struct MultipleDecisionNode: Codable, Identifiable {
    let id: String? // unique id for each node allow possibility of flat vs nested tree
    var question: String? // e.g.
    var branches: [String: String]? // e.g. "Yes" : id of next MultipleDecisionNode
    // alt: var branches: [String: MultipleDecisionNode]
    var result: String? // non-nil if no further branches
    var note: String?
    var tag: String? // use for any additional info needed by EP Mobile, e.g. showMap

    var isLeaf: Bool { result != nil }

    static let rootNodeId: String = "node-root" // root node ID = Self.rootNodeId
}


extension MultipleDecisionNode {
    static func loadDecisionNodes(from fileName: String) throws -> [MultipleDecisionNode]? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("File \(fileName).json not found")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            // Decode an array of MultipleDecisionNode
            let nodes = try JSONDecoder().decode([MultipleDecisionNode].self, from: data)
            return nodes
        } catch {
            print("Error loading JSON file: \(error)")
            return nil
        }
    }

    static func saveDecisionNdes(to fileName: String) throws { }

//    static func buildTree(from nodes: [MultipleDecisionNode]) -> MultipleDecisionNode? {
//        guard let rootNode = nodes.first(where: { $0.id == rootNodeId }) else { // Assuming a well-known root ID
//            print("Error: Root node '\(rootNodeId)' not found.")
//            return nil
//        }
//
//        var nodeMap: [String: MultipleDecisionNode] = [:]
//        for node in nodes {
//            nodeMap[node.id] = node // nodes stored in dictionary
//        }
//
//        func populateBranches(node: inout MultipleDecisionNode) {
//            guard let branchIDs = node.branches else { return }
//
//            var actualChildBranches: [String: MultipleDecisionNode] = [:]
//            for (answerOption, childId) in branchIDs {
//                if var childNode = nodeMap[childId] {
//                    populateBranches(node: &childNode)
//                    actualChildBranches[answerOption] = childNode
//                } else {
//                    print("Error: Child node with ID '\(childId)' not found.")
//                }
//
//            }
//        }
//        return rootNode
//    }
}


