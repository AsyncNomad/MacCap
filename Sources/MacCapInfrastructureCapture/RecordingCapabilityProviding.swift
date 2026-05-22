import AVFoundation
import Foundation
import MacCapDomain
import ScreenCaptureKit

@MainActor
public protocol RecordingCapabilityProviding {
    func preferredVideoCodecLabel(for preset: RecordingQualityPreset) -> String
}

@MainActor
public struct RecordingCapabilityProvider: RecordingCapabilityProviding {
    public init() {}

    public func preferredVideoCodecLabel(for preset: RecordingQualityPreset) -> String {
        let supportedTypes = SCRecordingOutputConfiguration().availableVideoCodecTypes
        let selectedType = preset.preferredCodecType(from: supportedTypes)

        switch selectedType {
        case .hevc:
            return "HEVC"
        case .h264:
            return "H.264"
        default:
            return selectedType.rawValue
        }
    }
}
