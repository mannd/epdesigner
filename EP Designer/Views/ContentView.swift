//
//  ContentView.swift
//  EP Designer
//
//  Created by David Mann on 9/13/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State var root: DecisionNode
    @State private var expanded: Set<String> = []
    @State private var selectedNodeID: String? = nil
    @State private var refreshID = UUID()
    @State private var showingImporter = false
    @State private var showingExporter = false
    @State private var showingNewConfirm = false
    @State private var pendingNew = false
    @State private var showingOpenConfirm = false
    @State private var pendingOpen = false
    @State private var currentFileURL: URL? = nil
    @State private var isDirty: Bool = false
    @EnvironmentObject private var commandCenter: CommandCenter

    // Dynamic window title reflecting the current file name (macOS)
    private var windowTitle: String {
        let appTitle = "EP Designer"
        guard let url = currentFileURL else { return appTitle }
        let name = url.deletingPathExtension().lastPathComponent
        if name.isEmpty { return appTitle }
        return "\(appTitle) - \(name)"
    }

    var body: some View {
        NavigationStack {
            NavigationSplitView {
                // Sidebar
                ScrollView {
                    NodeListView(node: root, expanded: $expanded, selection: Binding<DecisionNode?>(
                        get: { selectedNodeID.flatMap { findNode(in: root, id: $0) } },
                        set: { selectedNodeID = $0?.id }
                    ))
                        .id(refreshID)
                        .padding()
                        .navigationTitle("Decision Tree")
                }
            } detail: {
                if let id = selectedNodeID, let node = findNode(in: root, id: id) {
                    let nodeBinding = Binding<DecisionNode>(
                            get: {
                                // Always re-fetch from the current root so edits persist
                                return findNode(in: root, id: id) ?? node
                            },
                            set: { updatedNode in
                                // The setter is called when NodeEditorView tries to write a new value.
                                // This is where you perform your update logic.
                                replaceNode(in: &root, with: updatedNode)

                                // Keep the same selection id (stable)
                                selectedNodeID = updatedNode.id

                                // Trigger UI refresh for both panels
                                refreshID = UUID()
                                
                                isDirty = true
                            }
                        )
                    NodeEditorView(
                        node: nodeBinding,
                        onChange: { updated in
                            replaceNode(in: &root, with: updated)
                            // Trigger UI refresh for both panels
                            refreshID = UUID()
                            // Keep the same selection id (stable)
                            selectedNodeID = updated.id
                            isDirty = true
                        }
                    )
                    .id(node.id)
                } else {
                    Text("Select a node")
                        .foregroundColor(.secondary)
                }
            }
            .navigationDestination(for: DecisionNode.self) { node in
                let nodeBinding = Binding<DecisionNode>(
                        get: {
                            // Always re-fetch from the current root so edits persist
                            return findNode(in: root, id: node.id) ?? node
                        },
                        set: { updatedNode in
                            // The setter is called when NodeEditorView tries to write a new value.
                            // This is where you perform your update logic.
                            replaceNode(in: &root, with: updatedNode)

                            // Keep the same selection id (stable)
                            selectedNodeID = updatedNode.id

                            // Trigger UI refresh for both panels
                            refreshID = UUID()
                            isDirty = true
                        }
                    )
                NodeEditorView(
                    node: nodeBinding
                )
            }
        } // NavigationStack
        #if os(macOS)
        .macOSWindowTitle(windowTitle)
        #endif
        .toolbar {
            ToolbarItemGroup(placement: .automatic) {
                Button {
                    if isDirty {
                        showingNewConfirm = true
                    } else {
                        // No unsaved changes; proceed directly to new
                        root = DecisionNode.new()
                        expanded.removeAll()
                        selectedNodeID = nil
                        refreshID = UUID()
                        currentFileURL = nil
                        isDirty = false
                        commandCenter.canSave = false
                    }
                } label: {
                    Label("New", systemImage: "doc")
                }
                .accessibilityHint("Start a new blank decision tree. You can save the current tree first.")
                #if os(macOS)
                .help("Create a new blank decision tree")
                #endif

                Button {
                    if isDirty {
                        showingOpenConfirm = true
                    } else {
                        // No unsaved changes; open directly
                        showingImporter = true
                    }
                } label: {
                    Label("Open", systemImage: "folder")
                }
                .accessibilityHint("Open a decision tree from a JSON file. You can save the current tree first.")
                #if os(macOS)
                .help("Open a decision tree from disk")
                #endif

                Button {
                    if let url = currentFileURL {
                        do {
                            try root.save(to: url)
                            isDirty = false
                            commandCenter.canSave = false
                        } catch {
                            print("Failed to save in place: \(error)")
                        }
                    } else {
                        showingExporter = true
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .accessibilityHint("Save the current decision tree to a JSON file.")
                #if os(macOS)
                .help("Save the current decision tree")
                #endif
                .disabled(!isDirty)
            }
        }
        .fileImporter(isPresented: $showingImporter, allowedContentTypes: [UTType.json]) { result in
            do {
                let url = try result.get()
                var needsStop = false
                #if os(iOS) || os(visionOS) || os(tvOS) || os(watchOS) || os(macOS)
                if url.startAccessingSecurityScopedResource() { needsStop = true }
                #endif
                let loaded = try DecisionNode.load(from: url)
                if needsStop { url.stopAccessingSecurityScopedResource() }
                DispatchQueue.main.async {
                    root = loaded
                    // Reset selection/expanded state for new tree
                    expanded.removeAll()
                    selectedNodeID = nil
                    refreshID = UUID()
                    currentFileURL = url
                    isDirty = false
                    commandCenter.canSave = false
                }
            } catch {
                print("Failed to open: \(error)")
            }
        }
        .fileExporter(isPresented: $showingExporter, document: DecisionNodeDocument(node: root), contentType: UTType.json, defaultFilename: defaultFilename()) { result in
            switch result {
            case .failure(let error):
                print("Failed to save: \(error)")
                pendingNew = false
                pendingOpen = false
            case .success(let url):
                currentFileURL = url
                isDirty = false
                commandCenter.canSave = false
                if pendingNew {
                    pendingNew = false
                    root = DecisionNode.new()
                    expanded.removeAll()
                    selectedNodeID = nil
                    refreshID = UUID()
                    currentFileURL = nil
                    isDirty = false
                    commandCenter.canSave = false
                } else if pendingOpen {
                    pendingOpen = false
                    showingImporter = true
                }
            }
        }
        .alert("Start a New Decision Tree?", isPresented: $showingNewConfirm) {
            Button("Save and New") {
                pendingNew = true
                showingExporter = true
            }
            Button("Discard and New", role: .destructive) {
                root = DecisionNode.new()
                expanded.removeAll()
                selectedNodeID = nil
                refreshID = UUID()
                currentFileURL = nil
                isDirty = false
                commandCenter.canSave = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to save your current tree before creating a new one?")
        }
        .alert("Open a Decision Tree?", isPresented: $showingOpenConfirm) {
            Button("Save and Open") {
                pendingOpen = true
                showingExporter = true
            }
            Button("Discard and Open", role: .destructive) {
                showingImporter = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Do you want to save your current tree before opening another file?")
        }
        .onReceive(commandCenter.$newFileRequested) { requested in
            if requested {
                commandCenter.newFileRequested = false
                if isDirty {
                    showingNewConfirm = true
                } else {
                    root = DecisionNode.new()
                    expanded.removeAll()
                    selectedNodeID = nil
                    refreshID = UUID()
                    currentFileURL = nil
                    isDirty = false
                    commandCenter.canSave = false
                }
            }
        }
        .onReceive(commandCenter.$openFileRequested) { requested in
            if requested {
                commandCenter.openFileRequested = false
                if isDirty {
                    showingOpenConfirm = true
                } else {
                    showingImporter = true
                }
            }
        }
        .onReceive(commandCenter.$saveFileRequested) { requested in
            if requested {
                commandCenter.saveFileRequested = false
                if let url = currentFileURL {
                    do {
                        try root.save(to: url)
                        isDirty = false
                        commandCenter.canSave = false
                    } catch {
                        print("Failed to save in place: \(error)")
                    }
                } else {
                    showingExporter = true
                }
            }
        }
        .onReceive(commandCenter.$saveAsFileRequested) { requested in
            if requested {
                commandCenter.saveAsFileRequested = false
                showingExporter = true
            }
        }
        .onAppear {
            commandCenter.canSave = isDirty
        }
        .onChange(of: isDirty) { oldValue, newValue in
            commandCenter.canSave = newValue
        }
        // This binds the sidebar selection to the @State property
        .navigationSplitViewColumnWidth(min: 200, ideal: 250)
    }

    private func replaceNode(in node: inout DecisionNode, with updated: DecisionNode) {
        if node.id == updated.id {
            node = updated
            return
        }
        guard var branches = node.branches else { return }
        for i in branches.indices {
            var mutableChild = branches[i]
            replaceNode(in: &mutableChild, with: updated)
            branches[i] = mutableChild
        }
        node.branches = branches
    }

    private func findNode(in node: DecisionNode, id: String) -> DecisionNode? {
        if node.id == id { return node }
        guard let branches = node.branches else { return nil }
        for child in branches {
            if let found = findNode(in: child, id: id) { return found }
        }
        return nil
    }

    private func defaultFilename() -> String {
        let base = root.label.isEmpty ? "DecisionTree" : root.label
        return base.replacingOccurrences(of: " ", with: "_")
    }
}

 
struct DecisionNodeDocument: FileDocument {
    static var readableContentTypes: [UTType] { [UTType.json] }
    var node: DecisionNode
    init(node: DecisionNode) { self.node = node }
    init(configuration: ReadConfiguration) throws {
        // Read data from the provided FileWrapper (non-optional)
        guard let data = configuration.file.regularFileContents else {
            throw CocoaError(.fileReadUnknown)
        }
        // Write to a temporary URL so we can reuse the existing `DecisionNode.load(from:)`
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("json")
        try data.write(to: tempURL)
        self.node = try DecisionNode.load(from: tempURL)
    }
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let temp = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(UUID().uuidString).appendingPathExtension("json")
        try node.save(to: temp)
        let data = try Data(contentsOf: temp)
        return FileWrapper(regularFileWithContents: data)
    }
}

#if os(macOS)
import AppKit

private struct WindowTitleSetter: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        content
            .background(TitleSetterRepresentable(title: title))
    }

    private struct TitleSetterRepresentable: NSViewRepresentable {
        let title: String

        func makeNSView(context: Context) -> NSView {
            let view = NSView()
            DispatchQueue.main.async {
                updateWindowTitle(for: view)
            }
            return view
        }

        func updateNSView(_ nsView: NSView, context: Context) {
            DispatchQueue.main.async {
                updateWindowTitle(for: nsView)
            }
        }

        private func updateWindowTitle(for view: NSView) {
            guard let window = view.window else { return }
            window.title = title
        }
    }
}

private extension View {
    func macOSWindowTitle(_ title: String) -> some View {
        self.modifier(WindowTitleSetter(title: title))
    }
}
#endif

// Preview
#Preview {
    ContentView(root: .sampleTree)
}

