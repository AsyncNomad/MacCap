import AppKit
import Foundation

@MainActor
protocol WorkspaceControlling {
    func revealFile(at url: URL)
    func revealDirectory(at url: URL)
    func chooseDirectory(startingAt url: URL) -> URL?
}

@MainActor
final class AppKitWorkspaceController: WorkspaceControlling {
    func revealFile(at url: URL) {
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    func revealDirectory(at url: URL) {
        NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: url.path)
    }

    func chooseDirectory(startingAt url: URL) -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.allowsMultipleSelection = false
        panel.directoryURL = url
        panel.prompt = "선택"

        guard panel.runModal() == .OK else {
            return nil
        }

        return panel.url
    }
}
