import AVFoundation
import Foundation
import ScreenCaptureKit

public enum RecordingQualityPreset: String, CaseIterable, Identifiable, Sendable {
    case compact
    case balanced
    case original

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .compact:
            "일반 화질(기본값)"
        case .balanced:
            "고화질"
        case .original:
            "원본"
        }
    }

    public var description: String {
        switch self {
        case .compact:
            "일반 공유 화면과 회의 녹화에 적합한 기본 설정"
        case .balanced:
            "선명도를 높인 고화질 설정"
        case .original:
            "Retina 기준 최대한 원본에 가깝게 저장"
        }
    }

    public var storageProfile: String {
        switch self {
        case .compact:
            "중간 용량"
        case .balanced:
            "대용량"
        case .original:
            "최대 용량"
        }
    }

    public var captureResolution: SCCaptureResolutionType {
        switch self {
        case .compact:
            .nominal
        case .balanced, .original:
            .best
        }
    }

    public var frameRate: Int32 {
        switch self {
        case .compact, .balanced:
            30
        case .original:
            60
        }
    }

    public var usesRetinaScale: Bool {
        switch self {
        case .compact:
            false
        case .balanced, .original:
            true
        }
    }

    public func preferredCodecType(from types: [AVVideoCodecType]) -> AVVideoCodecType {
        switch self {
        case .compact:
            if types.contains(.h264) {
                return .h264
            }
            if types.contains(.hevc) {
                return .hevc
            }
        case .balanced:
            if types.contains(.hevc) {
                return .hevc
            }
            if types.contains(.h264) {
                return .h264
            }
        case .original:
            if types.contains(.hevc) {
                return .hevc
            }
            if types.contains(.h264) {
                return .h264
            }
        }

        return types.first ?? .h264
    }

    public func estimatedVideoCodecLabel(supportedHEVC: Bool = true) -> String {
        switch self {
        case .compact:
            "H.264"
        case .balanced, .original:
            supportedHEVC ? "HEVC" : "H.264"
        }
    }

    public func outputSize(for display: CaptureDisplay) -> (width: Int, height: Int) {
        let scaleFactor = usesRetinaScale ? max(display.scaleFactor, 1.0) : 1.0
        return (
            width: Int(Double(display.width) * scaleFactor),
            height: Int(Double(display.height) * scaleFactor)
        )
    }

    public func specificationLine(for display: CaptureDisplay?) -> String {
        let resolutionText: String
        if let display {
            let size = outputSize(for: display)
            resolutionText = "\(size.width) x \(size.height)"
        } else {
            resolutionText = usesRetinaScale ? "Retina 기준 고해상도" : "디스플레이 기본 해상도"
        }

        return "\(resolutionText) · \(frameRate)fps · \(estimatedVideoCodecLabel()) · \(storageProfile)"
    }
}
