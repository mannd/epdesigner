import SwiftUI

struct NodeEditorView: View {
    @Binding var node: DecisionNode
    @State private var selectedChildID: String? = nil
    var onChange: (DecisionNode) -> Void

    init(node: Binding<DecisionNode>, onChange: @escaping (DecisionNode) -> Void = { _ in }) {
        self._node = node
        self.onChange = onChange
    }

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { selectedChildID = nil }
            Form {
                Section {
                    HStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .leading, spacing: 12) {
                            TextField("Question", text: Binding(
                                get: { node.question ?? "" },
                                set: {
                                    print("Question set to:", $0)
                                    node.question = $0.isEmpty ? nil : $0 }
                            ))
                            TextField("Result (leaf)", text: Binding(
                                get: { node.result ?? "" },
                                set: { node.result = $0.isEmpty ? nil : $0 }
                            ))
                            TextField("Note", text: Binding(
                                get: { node.note ?? "" },
                                set: { node.note = $0.isEmpty ? nil : $0 }
                            ))
                            TextField("Tag", text: Binding(
                                get: { node.tag ?? "" },
                                set: { node.tag = $0.isEmpty ? nil : $0 }
                            ))
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.secondary.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .frame(maxWidth: 640)
                        Spacer(minLength: 0)
                    }
                } header: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.grid.2x2")
                        Text("Node")
                            .font(.title3.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .textCase(nil)
                    .padding(.top, 4)
                } footer: {
                    Divider().padding(.vertical, 4)
                }

                Section {
                    HStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .leading, spacing: 12) {
                            let sorted = (node.branches ?? [:]).sorted { $0.key < $1.key }
                            if sorted.isEmpty {
                                Text("No branches").foregroundStyle(.secondary)
                            } else {
                                ForEach(sorted, id: \.key) { key, child in
                                    HStack {
                                        Text(key).bold()
                                        Text(child.question ?? child.result ?? "Untitled")
                                            .lineLimit(1)
                                            .foregroundStyle(.secondary)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture { selectedChildID = child.id }
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.accentColor.opacity(selectedChildID == child.id ? 0.12 : 0))
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedChildID == child.id ? Color.accentColor : Color.clear, lineWidth: 1)
                                    )
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
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.secondary.opacity(0.08))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        )
                        .frame(maxWidth: 640)
                        Spacer(minLength: 0)
                    }
                } header: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.triangle.branch")
                        Text("Branches")
                            .font(.title3.weight(.semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .textCase(nil)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(node.question ?? "Node Details")
    }

    private func addBranch() {
        let newKeyBase = "New Branch"
        var key = newKeyBase
        var i = 1
        let existing = node.branches ?? [:]
        while existing.keys.contains(key) {
            i += 1
            key = "\(newKeyBase) \(i)"
        }
        var branches = existing
        branches[key] = DecisionNode(question: "New Child")
        node.branches = branches
    }

    private func removeBranch(_ key: String) {
        guard var branches = node.branches else { return }
        branches.removeValue(forKey: key)
        node.branches = branches.isEmpty ? nil : branches
    }
}

#Preview {
    NavigationStack {
        NodeEditorView(node: .constant(.sampleTree)) { _ in }
    }
}
