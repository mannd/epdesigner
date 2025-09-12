//
//  EP_DesignerTests.swift
//  EP DesignerTests
//
//  Created by David Mann on 6/18/25.
//

import Foundation
import Testing
@testable import EP_Designer

struct EP_DesignerTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func testSaveAndLoadNestedTree() throws {
        let tree = DecisionNode(
            id: DecisionNode.rootNodeId,
            question: "Favorite color?",
            branches: [
                "Red": DecisionNode(result: "You like red!"),
                "Blue": DecisionNode(result: "You like blue!")
            ]
        )

        // Save to a temporary file
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("tree_test.json")
        try tree.save(to: url)

        // Load back
        let loadedTree = try DecisionNode.load(from: url)

        #expect(tree.id == loadedTree.id)
        #expect(tree.question == loadedTree.question)
        #expect(loadedTree.branches != nil)
        #expect(tree.branches!.count == loadedTree.branches!.count)
        #expect(loadedTree.branches?["Red"]?.result == "You like red!")
        #expect(loadedTree.branches?["Blue"]?.result == "You like blue!")
        #expect(loadedTree.branches?["Red"]?.isLeaf ?? false)
        #expect(loadedTree.branches?["Blue"]?.isLeaf ?? false)

        // Clean up
        try? FileManager.default.removeItem(at: url)

    }

}
