import AVFoundation
import CoreGraphics
import Foundation
import MacCapDomain

struct PermissionCoordinator {
    func ensureScreenRecordingAccess() async throws {
        if CGPreflightScreenCaptureAccess() {
            return
        }

        let granted = CGRequestScreenCaptureAccess()
        if !granted {
            throw RecordingError.screenPermissionDenied
        }
    }

    func ensureMicrophoneAccessIfNeeded(includeMicrophone: Bool) async throws {
        guard includeMicrophone else {
            return
        }

        switch AVCaptureDevice.authorizationStatus(for: .audio) {
        case .authorized:
            return
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .audio)
            if !granted {
                throw RecordingError.microphonePermissionDenied
            }
        default:
            throw RecordingError.microphonePermissionDenied
        }
    }
}
