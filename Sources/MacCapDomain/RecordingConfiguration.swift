import Foundation

public struct RecordingConfiguration: Sendable {
    public let display: CaptureDisplay
    public let includeMicrophone: Bool
    public let outputDirectoryURL: URL
    public let showsCursor: Bool
    public let qualityPreset: RecordingQualityPreset

    public init(
        display: CaptureDisplay,
        includeMicrophone: Bool,
        outputDirectoryURL: URL,
        showsCursor: Bool = true,
        qualityPreset: RecordingQualityPreset = .compact
    ) {
        self.display = display
        self.includeMicrophone = includeMicrophone
        self.outputDirectoryURL = outputDirectoryURL
        self.showsCursor = showsCursor
        self.qualityPreset = qualityPreset
    }
}
