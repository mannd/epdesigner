import SwiftUI

struct NodeEditorView: View {
    @State private var workingCopy: DecisionNode
    var onChange: (DecisionNode) -> Void

    init(node: DecisionNode, onChange: @escaping (DecisionNode) -> Void = { _ in }) {
        _workingCopy = State(initialValue: node)
        self.onChange = onChange
    }

    var body: some View {
        Form {
            Section("Node") {
                TextField("Question", text: Binding(
                    get: { workingCopy.question ?? "" },
                    set: { workingCopy.question = $0.isEmpty ? nil : $0 }
                ))
                TextField("Result (leaf)", text: Binding(
                    get: { workingCopy.result ?? "" },
                    set: { workingCopy.result = $0.isEmpty ? nil : $0 }
                ))
                TextField("Note", text: Binding(
                    get: { workingCopy.note ?? "" },
                    set: { workingCopy.note = $0.isEmpty ? nil : $0 }
                ))
                TextField("Tag", text: Binding(
                    get: { workingCopy.tag ?? "" },
                    set: { workingCopy.tag = $0.isEmpty ? nil : $0 }
                ))
            }

            Section("Branches") {
                let sorted = (workingCopy.branches ?? [:]).sorted { $0.key < $1.key }
                if sorted.isEmpty {
                    Text("No branches").foregroundStyle(.secondary)
                } else {
                    ForEach(sorted, id: \.key) { key, child in
                        HStack {
                            Text(key).bold()
                            Spacer()
                            Text(child.question ?? child.result ?? "Untitled")
                                .lineLimit(1)
                                .foregroundStyle(.secondary)
                        }
                        .contextMenu {
                            Button(role: .destructive) { removeBranch(key) } label: {
                                Label("Delete Branch", systemImage: "trash")
                            }
                        }
                    }
                }
                Button {
                    addBranch()
                } label: {
                    Label("Add Branch", systemImage: "plus")
                }
            }
        }
        .navigationTitle(workingCopy.question ?? "Node Details")
        .onChange(of: workingCopy) { newValue in
            onChange(newValue)
        }
    }

    private func addBranch() {
        let newKeyBase = "New Branch"
        var key = newKeyBase
        var i = 1
        let existing = workingCopy.branches ?? [:]
        while existing.keys.contains(key) {
            i += 1
            key = "\(newKeyBase) \(i)"
        }
        var branches = existing
        branches[key] = DecisionNode(question: "New Child")
        workingCopy.branches = branches
    }

    private func removeBranch(_ key: String) {
        guard var branches = workingCopy.branches else { return }
        branches.removeValue(forKey: key)
        workingCopy.branches = branches.isEmpty ? nil : branches
    }
}

#Preview {
    NavigationStack {
        NodeEditorView(node: .sampleTree) { _ in }
    }
}

