import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var state: AppState

    private let naxyOrange = Color(red: 0.97, green: 0.41, blue: 0)

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            nowPlaying
            Divider()
            controls
            Divider()
            startupRow
            Divider()
            footer
        }
        .frame(width: 300)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Image(systemName: "radio.fill")
                .font(.title2)
                .foregroundStyle(naxyOrange)
            VStack(alignment: .leading, spacing: 2) {
                Text("NAXI RADIO")
                    .font(.system(size: 15, weight: .bold))
                Text("96.9 MHz · Beograd, Srbija")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Now Playing

    private var nowPlaying: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("SADA SVIRA", systemImage: "music.note")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)

            if state.currentArtist.isEmpty && state.currentSong.isEmpty {
                Text("Učitavanje...")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                if !state.currentArtist.isEmpty {
                    Text(state.currentArtist)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if !state.currentSong.isEmpty {
                    Text(state.currentSong)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                if !state.currentShow.isEmpty {
                    Text(state.currentShow)
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Controls

    private var controls: some View {
        VStack(spacing: 10) {
            Button {
                state.togglePlayPause()
            } label: {
                Group {
                    if state.isBuffering {
                        ProgressView()
                            .scaleEffect(0.8)
                            .frame(width: 52, height: 52)
                    } else {
                        Image(systemName: state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(naxyOrange)
                    }
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 8) {
                Image(systemName: "speaker.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Slider(value: Binding(
                    get: { state.volume },
                    set: { state.setVolume($0) }
                ), in: 0...1)
                .tint(naxyOrange)
                Image(systemName: "speaker.wave.3.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Startup Toggle

    private var startupRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: Binding(
                get: { state.launchAtLogin },
                set: { _ in state.toggleLaunchAtLogin() }
            )) {
                HStack(spacing: 6) {
                    Image(systemName: "power")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text("Pokreni pri startu Maca")
                        .font(.system(size: 13))
                }
            }
            .toggleStyle(.checkbox)

            if !state.loginItemStatus.isEmpty {
                Text(state.loginItemStatus)
                    .font(.system(size: 10))
                    .foregroundStyle(.orange)
                    .padding(.leading, 22)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Footer

    private var footer: some View {
        HStack(spacing: 0) {
            Button {
                NSWorkspace.shared.open(URL(string: "https://www.naxi.rs/live")!)
            } label: {
                Label("naxi.rs", systemImage: "globe")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()

            Button {
                state.showAbout()
            } label: {
                Label("O appu", systemImage: "info.circle")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Zatvori", systemImage: "xmark.circle")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
