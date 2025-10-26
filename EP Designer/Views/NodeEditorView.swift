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
                            // Label (branch answer) editor
                            TextField("Label (answer from parent, e.g. Blue)", text: $node.label)

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
                    .padding(.horizontal, 16)
                } header: {
                    HStack {
                        Spacer(minLength: 0)
                        HStack(spacing: 8) {
                            Image(systemName: "square.grid.2x2")
                            Text("Node")
                                .font(.title3.weight(.semibold))
                        }
                        .frame(maxWidth: 640)
                        .multilineTextAlignment(.center)
                        .textCase(nil)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                } footer: {
                    Divider().padding(.vertical, 4)
                }

                Section {
                    HStack {
                        Spacer(minLength: 0)
                        VStack(alignment: .leading, spacing: 12) {
                            let children = node.branches ?? []
                            if children.isEmpty {
                                Text("No branches").foregroundStyle(.secondary)
                            } else {
                                ForEach(children, id: \.id) { child in
                                    HStack {
                                        Text(child.label).bold()
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
                                        Button(role: .destructive) { removeBranch(child.label) } label: {
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
                    .padding(.horizontal, 16)
                } header: {
                    HStack {
                        Spacer(minLength: 0)
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.triangle.branch")
                            Text("Branches")
                                .font(.title3.weight(.semibold))
                        }
                        .frame(maxWidth: 640)
                        .multilineTextAlignment(.center)
                        .textCase(nil)
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationTitle(node.question ?? "Node Details")
    }

    private func addBranch() {
        let base = "New Branch"
        var label = base
        var i = 1
        var children = node.branches ?? []
        while children.contains(where: { $0.label == label }) {
            i += 1
            label = "\(base) \(i)"
        }
        let newChild = DecisionNode(label: label, question: "New Child")
        children.append(newChild)
        node.branches = children
    }

    private func removeBranch(_ label: String) {
        guard var children = node.branches else { return }
        children.removeAll { $0.label == label }
        node.branches = children.isEmpty ? nil : children
    }
}

#Preview {
    NavigationStack {
        NodeEditorView(node: .constant(.sampleTree)) { _ in }
    }
}

