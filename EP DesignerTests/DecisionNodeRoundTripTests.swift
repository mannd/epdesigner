import Foundation
import Testing
@testable import EP_Designer

@Suite("DecisionNode JSON round-trip")
struct DecisionNodeRoundTripTests {

    private func tempURL(_ name: String = UUID().uuidString) -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent("DecisionNodeTests_\(name).json")
    }

    @Test("Round-trip simple leaf node")
    func roundTripLeaf() throws {
        var node = DecisionNode(label: "Leaf Label", question: nil, branches: nil, result: "Done", note: "n", tag: "t")
        let url = tempURL("leaf")
        defer { try? FileManager.default.removeItem(at: url) }

        try node.save(to: url)
        let loaded = try DecisionNode.load(from: url)

        #expect(loaded.id == node.id)
        #expect(loaded.label == node.label)
        #expect(loaded.result == node.result)
        #expect(loaded.branches == nil)
        #expect(loaded.isLeaf)
    }

    @Test("Round-trip small tree with branches")
    func roundTripTree() throws {
        let child1 = DecisionNode(label: "Red", question: "Why red?", branches: nil, result: nil)
        let child2 = DecisionNode(label: "Blue", question: nil, branches: nil, result: "Pick blue")
        var root = DecisionNode(label: "", question: "Favorite color?", branches: [child1, child2], result: nil)
        let url = tempURL("tree")
        defer { try? FileManager.default.removeItem(at: url) }

        try root.save(to: url)
        let loaded = try DecisionNode.load(from: url)

        #expect(loaded.id == root.id)
        #expect(loaded.question == root.question)
        let loadedBranches = try #require(loaded.branches)
        #expect(loadedBranches.count == 2)
        #expect(loadedBranches[0].label == "Red")
        #expect(loadedBranches[1].result == "Pick blue")
        #expect(!loaded.isLeaf)
    }
}
