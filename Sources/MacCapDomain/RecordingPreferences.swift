import Foundation

public struct RecordingPreferences: Sendable {
    public var selectedDisplayID: UInt32?
    public var includeMicrophone: Bool
    public var outputDirectoryURL: URL
    public var qualityPreset: RecordingQualityPreset

    public init(
        selectedDisplayID: UInt32? = nil,
        includeMicrophone: Bool = false,
        outputDirectoryURL: URL,
        qualityPreset: RecordingQualityPreset = .compact
    ) {
        self.selectedDisplayID = selectedDisplayID
        self.includeMicrophone = includeMicrophone
        self.outputDirectoryURL = outputDirectoryURL
        self.qualityPreset = qualityPreset
    }
}
