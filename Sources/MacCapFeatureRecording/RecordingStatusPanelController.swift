import AppKit
import MacCapDomain
import SwiftUI

@MainActor
final class RecordingStatusPanelController {
    private var panel: NSPanel?

    func present(elapsedTimeText: String, includesMicrophone: Bool, stopAction: @escaping () -> Void) {
        let panel = panel ?? makePanel()
        self.panel = panel

        panel.contentView = NSHostingView(
            rootView: RecordingStatusPanelView(
                elapsedTimeText: elapsedTimeText,
                includesMicrophone: includesMicrophone,
                stopAction: stopAction
            )
        )

        position(panel)

        if !panel.isVisible {
            panel.orderFrontRegardless()
        }
    }

    func dismiss() {
        panel?.orderOut(nil)
    }

    private func makePanel() -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 240, height: 72),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.titleVisibility = .hidden
        panel.titlebarAppearsTransparent = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        return panel
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main ?? NSScreen.screens.first else {
            return
        }

        let visibleFrame = screen.visibleFrame
        let origin = NSPoint(
            x: visibleFrame.maxX - panel.frame.width - 20,
            y: visibleFrame.maxY - panel.frame.height - 20
        )
        panel.setFrameOrigin(origin)
    }
}

private struct RecordingStatusPanelView: View {
    let elapsedTimeText: String
    let includesMicrophone: Bool
    let stopAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(.red)
                .frame(width: 10, height: 10)

            VStack(alignment: .leading, spacing: 3) {
                Text(elapsedTimeText)
                    .font(.system(size: 15, weight: .semibold))

                Text(includesMicrophone ? "시스템 오디오 + 마이크" : "시스템 오디오")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)

            Button(action: stopAction) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 11, weight: .bold))
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.borderless)
            .background(Circle().fill(Color.white.opacity(0.85)))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 240, height: 72)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Color.white.opacity(0.7), lineWidth: 0.8)
        )
    }
}
