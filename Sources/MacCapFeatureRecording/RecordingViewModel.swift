import Combine
import Foundation
import MacCapDomain
import MacCapInfrastructureCapture

@MainActor
public final class RecordingViewModel: ObservableObject {
    @Published public private(set) var displays: [CaptureDisplay] = []
    @Published public var selectedDisplayID: UInt32? {
        didSet { persistPreferences() }
    }
    @Published public var includeMicrophone = false {
        didSet { persistPreferences() }
    }
    @Published public var outputDirectoryURL: URL {
        didSet { persistPreferences() }
    }
    @Published public var qualityPreset: RecordingQualityPreset {
        didSet { persistPreferences() }
    }
    @Published public var isSettingsPresented = false
    @Published public private(set) var lifecycleState: RecordingLifecycleState = .idle
    @Published public private(set) var latestRecordingURL: URL?
    @Published public private(set) var errorMessage: String?
    @Published public private(set) var isBusy = false
    @Published public private(set) var elapsedTimeText = "00:00"

    private let controller: RecordingControlling
    private let preferencesStore: RecordingPreferencesStoring
    private let notifier: RecordingUserNotifying
    private let workspaceController: WorkspaceControlling
    private let capabilityProvider: RecordingCapabilityProviding
    private var timer: Timer?
    private var activeSession: RecordingSession?

    init(
        controller: RecordingControlling = ScreenCaptureRecordingController(),
        preferencesStore: RecordingPreferencesStoring = UserDefaultsRecordingPreferencesStore(),
        notifier: RecordingUserNotifying = RecordingNotificationService(),
        workspaceController: WorkspaceControlling = AppKitWorkspaceController(),
        capabilityProvider: RecordingCapabilityProviding = RecordingCapabilityProvider()
    ) {
        self.controller = controller
        self.preferencesStore = preferencesStore
        self.notifier = notifier
        self.workspaceController = workspaceController
        self.capabilityProvider = capabilityProvider
        let preferences = preferencesStore.load()
        self.selectedDisplayID = preferences.selectedDisplayID
        self.includeMicrophone = preferences.includeMicrophone
        self.outputDirectoryURL = preferences.outputDirectoryURL
        self.qualityPreset = preferences.qualityPreset
        self.controller.stateDidChange = { [weak self] state in
            self?.apply(state: state)
        }
    }

    public func load() async {
        notifier.prepare()
        await refreshDisplays()
    }

    public func refreshDisplays() async {
        isBusy = true
        defer { isBusy = false }

        do {
            let displays = try await controller.availableDisplays()
            self.displays = displays

            if let selectedDisplayID, displays.contains(where: { $0.displayID == selectedDisplayID }) {
                return
            }

            self.selectedDisplayID = displays.first?.displayID
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    public func toggleRecording() async {
        if activeSession == nil {
            await startRecording()
        } else {
            await stopRecording()
        }
    }

    public func revealLatestRecording() {
        guard let latestRecordingURL else {
            return
        }

        workspaceController.revealFile(at: latestRecordingURL)
    }

    public func revealOutputDirectory() {
        workspaceController.revealDirectory(at: outputDirectoryURL)
    }

    public func chooseOutputDirectory() {
        if let url = workspaceController.chooseDirectory(startingAt: outputDirectoryURL) {
            outputDirectoryURL = url
        }
    }

    public var canStartRecording: Bool {
        selectedDisplay != nil && !isBusy && activeSession == nil
    }

    public var isRecording: Bool {
        if case .recording = lifecycleState {
            return true
        }

        if case .stopping = lifecycleState {
            return true
        }

        return false
    }

    public var selectedDisplay: CaptureDisplay? {
        guard let selectedDisplayID else {
            return nil
        }

        return displays.first(where: { $0.displayID == selectedDisplayID })
    }

    private func startRecording() async {
        guard let selectedDisplay else {
            errorMessage = RecordingError.noDisplaysAvailable.localizedDescription
            return
        }

        isBusy = true
        errorMessage = nil

        do {
            let configuration = RecordingConfiguration(
                display: selectedDisplay,
                includeMicrophone: includeMicrophone,
                outputDirectoryURL: outputDirectoryURL,
                qualityPreset: qualityPreset
            )

            let session = try await controller.startRecording(with: configuration)
            latestRecordingURL = session.outputURL
        } catch {
            errorMessage = error.localizedDescription
        }

        isBusy = false
    }

    private func stopRecording() async {
        isBusy = true
        errorMessage = nil

        do {
            let session = try await controller.stopRecording()
            latestRecordingURL = session.outputURL
        } catch {
            errorMessage = error.localizedDescription
        }

        isBusy = false
    }

    private func apply(state: RecordingLifecycleState) {
        lifecycleState = state

        switch state {
        case .idle:
            activeSession = nil
            stopTimer()
        case .preparing:
            stopTimer()
        case .recording(let session):
            activeSession = session
            latestRecordingURL = session.outputURL
            startTimer(from: session.startedAt)
        case .stopping:
            stopTimer()
        case .finished(let session):
            latestRecordingURL = session.outputURL
            notifier.notifyRecordingSaved(at: session.outputURL)
            activeSession = nil
            stopTimer()
        case .failed(let message):
            errorMessage = message
            activeSession = nil
            stopTimer()
        }
    }

    private func startTimer(from startDate: Date) {
        stopTimer()
        updateElapsedTime(from: startDate)

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateElapsedTime(from: startDate)
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTimeText = "00:00"
    }

    private func updateElapsedTime(from startDate: Date) {
        let elapsed = max(0, Int(Date().timeIntervalSince(startDate)))
        let minutes = elapsed / 60
        let seconds = elapsed % 60
        elapsedTimeText = String(format: "%02d:%02d", minutes, seconds)
    }

    public var outputDirectoryName: String {
        let name = outputDirectoryURL.lastPathComponent
        return name.isEmpty ? outputDirectoryURL.path : name
    }

    public var primaryStatusText: String {
        switch lifecycleState {
        case .idle:
            "준비 완료"
        case .preparing:
            "녹화 준비 중"
        case .recording:
            "녹화 중"
        case .stopping:
            "저장 중"
        case .finished:
            "완료"
        case .failed:
            "오류"
        }
    }

    public var recordingModeLabel: String {
        includeMicrophone ? "시스템 오디오 + 마이크" : "시스템 오디오"
    }

    public var selectedQualitySummary: String {
        qualityPreset.specificationLine(
            for: selectedDisplay,
            codecLabel: capabilityProvider.preferredVideoCodecLabel(for: qualityPreset)
        )
    }

    public func qualitySummary(for preset: RecordingQualityPreset) -> String {
        preset.specificationLine(
            for: selectedDisplay,
            codecLabel: capabilityProvider.preferredVideoCodecLabel(for: preset)
        )
    }

    private func persistPreferences() {
        preferencesStore.save(
            RecordingPreferences(
                selectedDisplayID: selectedDisplayID,
                includeMicrophone: includeMicrophone,
                outputDirectoryURL: outputDirectoryURL,
                qualityPreset: qualityPreset
            )
        )
    }
}
