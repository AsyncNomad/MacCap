import Foundation

@MainActor
protocol RecordingUserNotifying {
    func prepare()
    func notifyRecordingSaved(at url: URL)
}
