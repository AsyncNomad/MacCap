import MacCapDomain
import SwiftUI

public struct RecordingRootView: View {
    @StateObject private var viewModel = RecordingViewModel()
    @State private var statusPanelController = RecordingStatusPanelController()

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Text("MacCap")
                    .font(.system(size: 42, weight: .semibold))

                Text(viewModel.primaryStatusText)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Button {
                    Task { await viewModel.toggleRecording() }
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 96, height: 96)

                        Image(systemName: viewModel.isRecording ? "stop.fill" : "record.circle")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isBusy || (!viewModel.isRecording && !viewModel.canStartRecording))

                VStack(spacing: 8) {
                    if let display = viewModel.selectedDisplay {
                        Label(display.name, systemImage: "display")
                    }

                    Label(viewModel.recordingModeLabel, systemImage: "waveform")
                    Label(viewModel.selectedQualitySummary, systemImage: "sparkles.tv")
                    Label(viewModel.outputDirectoryName, systemImage: "folder")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let latestRecordingURL = viewModel.latestRecordingURL {
                    Button("최근 녹화 보기") {
                        viewModel.revealLatestRecording()
                    }
                    .buttonStyle(.link)
                    .help(latestRecordingURL.path)
                }

                if let errorMessage = viewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 420)
                }
            }
            .frame(maxWidth: 520)

            Spacer()
        }
        .padding(40)
        .background(Color(nsColor: .windowBackgroundColor))
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $viewModel.isSettingsPresented) {
            RecordingSettingsView(viewModel: viewModel)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button {
                    viewModel.revealOutputDirectory()
                } label: {
                    Image(systemName: "folder")
                }

                Button {
                    viewModel.isSettingsPresented = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
        }
        .onChange(of: viewModel.lifecycleState) { _, state in
            syncFloatingPanel(for: state)
        }
        .onChange(of: viewModel.elapsedTimeText) { _, _ in
            syncFloatingPanel(for: viewModel.lifecycleState)
        }
    }

    private func syncFloatingPanel(for state: RecordingLifecycleState) {
        switch state {
        case .recording(let session):
            statusPanelController.present(
                elapsedTimeText: viewModel.elapsedTimeText,
                includesMicrophone: session.includesMicrophone
            ) {
                Task { await viewModel.toggleRecording() }
            }
        default:
            statusPanelController.dismiss()
        }
    }

}
