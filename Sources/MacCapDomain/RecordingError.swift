import Foundation

public enum RecordingError: LocalizedError, Sendable {
    case noDisplaysAvailable
    case displayUnavailable
    case screenPermissionDenied
    case microphonePermissionDenied
    case activeRecordingExists
    case noActiveRecording
    case outputDirectoryUnavailable
    case internalFailure(String)

    public var errorDescription: String? {
        switch self {
        case .noDisplaysAvailable:
            "녹화할 수 있는 디스플레이를 찾지 못했습니다."
        case .displayUnavailable:
            "선택한 디스플레이를 다시 찾지 못했습니다. 디스플레이 목록을 새로고침해 주세요."
        case .screenPermissionDenied:
            "화면 녹화 권한이 필요합니다. 시스템 설정에서 MacCap의 화면 및 시스템 오디오 접근을 허용해 주세요."
        case .microphonePermissionDenied:
            "마이크 녹음 권한이 필요합니다. 시스템 설정에서 MacCap의 마이크 접근을 허용해 주세요."
        case .activeRecordingExists:
            "이미 녹화가 진행 중입니다."
        case .noActiveRecording:
            "중지할 녹화 세션이 없습니다."
        case .outputDirectoryUnavailable:
            "녹화 파일을 저장할 폴더를 만들 수 없습니다."
        case .internalFailure(let message):
            message
        }
    }
}
