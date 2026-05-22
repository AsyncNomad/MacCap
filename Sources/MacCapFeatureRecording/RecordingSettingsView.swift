import MacCapDomain
import SwiftUI

struct RecordingSettingsView: View {
    @ObservedObject var viewModel: RecordingViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("설정")
                    .font(.title3.weight(.semibold))

                HStack {
                    Spacer()

                    Button("완료") {
                        dismiss()
                    }
                    .keyboardShortcut(.cancelAction)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 8)

            Form {
                Section("녹화 대상") {
                    Picker("디스플레이", selection: Binding(
                        get: { viewModel.selectedDisplayID ?? 0 },
                        set: { viewModel.selectedDisplayID = $0 }
                    )) {
                        ForEach(viewModel.displays) { display in
                            Text("\(display.name) · \(display.resolutionDescription)")
                                .tag(display.displayID)
                        }
                    }
                    .disabled(viewModel.isRecording)

                    Toggle("마이크 함께 녹음", isOn: $viewModel.includeMicrophone)
                        .disabled(viewModel.isRecording)
                }

                Section("화질 및 용량") {
                    VStack(spacing: 10) {
                        ForEach(RecordingQualityPreset.allCases) { preset in
                            Button {
                                viewModel.qualityPreset = preset
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: preset == viewModel.qualityPreset ? "largecircle.fill.circle" : "circle")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundStyle(preset == viewModel.qualityPreset ? Color.accentColor : .secondary)
                                        .padding(.top, 2)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(preset.title)
                                            .font(.headline)
                                            .foregroundStyle(.primary)

                                        Text(viewModel.qualitySummary(for: preset))
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        Text(preset.description)
                                            .font(.footnote)
                                            .foregroundStyle(.tertiary)
                                    }

                                    Spacer()
                                }
                                .padding(14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(preset == viewModel.qualityPreset ? Color.accentColor.opacity(0.08) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(preset == viewModel.qualityPreset ? Color.accentColor.opacity(0.35) : Color.secondary.opacity(0.08), lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isRecording)
                        }
                    }
                }

                Section("저장 위치") {
                    HStack {
                        Text(viewModel.outputDirectoryURL.path)
                            .lineLimit(2)
                            .textSelection(.enabled)
                            .foregroundStyle(.secondary)

                        Spacer()
                    }

                    HStack {
                        Button("위치 변경") {
                            viewModel.chooseOutputDirectory()
                        }

                        Button("폴더 보기") {
                            viewModel.revealOutputDirectory()
                        }
                        .disabled(viewModel.isBusy)
                    }
                }

                Section {
                    Button("디스플레이 새로고침") {
                        Task { await viewModel.refreshDisplays() }
                    }
                    .disabled(viewModel.isBusy || viewModel.isRecording)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.white)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: 520)
        .onExitCommand {
            dismiss()
        }
    }
}
