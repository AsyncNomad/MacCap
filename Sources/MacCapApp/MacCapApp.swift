import MacCapFeatureRecording
import SwiftUI

@main
struct MacCapApp: App {
    var body: some Scene {
        WindowGroup {
            RecordingRootView()
                .frame(minWidth: 820, minHeight: 560)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 920, height: 620)
    }
}
