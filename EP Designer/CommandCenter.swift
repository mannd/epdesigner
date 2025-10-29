import SwiftUI

final class CommandCenter: ObservableObject {
    @Published var newFileRequested = false
    @Published var openFileRequested = false
    @Published var saveFileRequested = false
    @Published var saveAsFileRequested = false
    @Published var closeWindowRequested = false

    func requestNewFile() {
        newFileRequested = true
    }

    func requestOpenFile() {
        openFileRequested = true
    }

    func requestSaveFile() {
        saveFileRequested = true
    }

    func requestSaveAsFile() {
        saveAsFileRequested = true
    }

    func requestCloseWindow() {
        closeWindowRequested = true
    }

    func resetRequests() {
        newFileRequested = false
        openFileRequested = false
        saveFileRequested = false
        saveAsFileRequested = false
        closeWindowRequested = false
    }
}
