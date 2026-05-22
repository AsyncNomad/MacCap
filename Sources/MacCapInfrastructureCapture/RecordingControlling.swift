import Foundation
import MacCapDomain

@MainActor
public protocol RecordingControlling: AnyObject {
    var stateDidChange: ((RecordingLifecycleState) -> Void)? { get set }

    func availableDisplays() async throws -> [CaptureDisplay]
    func startRecording(with configuration: RecordingConfiguration) async throws -> RecordingSession
    func stopRecording() async throws -> RecordingSession
}
