import Foundation

public struct RecordingSession: Equatable, Sendable {
    public let outputURL: URL
    public let startedAt: Date
    public let display: CaptureDisplay
    public let includesMicrophone: Bool

    public init(
        outputURL: URL,
        startedAt: Date,
        display: CaptureDisplay,
        includesMicrophone: Bool
    ) {
        self.outputURL = outputURL
        self.startedAt = startedAt
        self.display = display
        self.includesMicrophone = includesMicrophone
    }
}

public enum RecordingLifecycleState: Equatable, Sendable {
    case idle
    case preparing
    case recording(RecordingSession)
    case stopping(RecordingSession)
    case finished(RecordingSession)
    case failed(String)
}
