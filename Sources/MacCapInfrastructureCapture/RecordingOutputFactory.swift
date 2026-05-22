import AVFoundation
import Foundation
import MacCapDomain
import ScreenCaptureKit

struct RecordingOutputFactory {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func makeRecordingOutput(
        baseDirectoryURL: URL,
        qualityPreset: RecordingQualityPreset,
        delegate: SCRecordingOutputDelegate
    ) throws -> (SCRecordingOutput, URL) {
        let configuration = SCRecordingOutputConfiguration()
        let codecType = qualityPreset.preferredCodecType(from: configuration.availableVideoCodecTypes)
        let fileType = preferredFileType(
            from: configuration.availableOutputFileTypes,
            codecType: codecType
        )
        let outputURL = try makeOutputURL(baseDirectoryURL: baseDirectoryURL, fileType: fileType)

        configuration.outputFileType = fileType
        configuration.videoCodecType = codecType
        configuration.outputURL = outputURL

        return (SCRecordingOutput(configuration: configuration, delegate: delegate), outputURL)
    }

    private func preferredFileType(from types: [AVFileType], codecType: AVVideoCodecType) -> AVFileType {
        if codecType == .proRes422 {
            if types.contains(.mov) {
                return .mov
            }
        }

        if types.contains(.mp4) {
            return .mp4
        }

        if types.contains(.mov) {
            return .mov
        }

        return types.first ?? .mov
    }

    private func makeOutputURL(baseDirectoryURL: URL, fileType: AVFileType) throws -> URL {
        do {
            try fileManager.createDirectory(at: baseDirectoryURL, withIntermediateDirectories: true)
        } catch {
            throw RecordingError.outputDirectoryUnavailable
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let extensionName: String
        switch fileType {
        case .mp4:
            extensionName = "mp4"
        case .mov:
            extensionName = "mov"
        default:
            extensionName = "mov"
        }

        return baseDirectoryURL
            .appendingPathComponent("MacCap_\(formatter.string(from: Date()))")
            .appendingPathExtension(extensionName)
    }
}
