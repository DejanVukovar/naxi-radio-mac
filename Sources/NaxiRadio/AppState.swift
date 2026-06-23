import AVFoundation
import Cocoa
import Combine
import Foundation

class AppState: ObservableObject {
    @Published var isPlaying = false
    @Published var volume: Double = 0.8
    @Published var currentArtist = ""
    @Published var currentSong = ""
    @Published var currentShow = ""
    @Published var isBuffering = false
    @Published var launchAtLogin = false
    @Published var loginItemStatus: String = ""

    private var player: AVPlayer?
    private var rateObserver: NSKeyValueObservation?
    private var statusObserver: NSKeyValueObservation?

    static let streamURL = URL(string: "https://naxi128ssl.streaming.rs:9152/;stream.nsv")!
    static let nowPlayingURL = URL(string: "https://www.naxi.rs/live")!

    init() {
        setupPlayer()
        play()
        scheduleNowPlayingUpdates()
        refreshLoginItemStatus()
    }

    // MARK: - Player

    private func setupPlayer() {
        let item = AVPlayerItem(url: Self.streamURL)
        player = AVPlayer(playerItem: item)
        player?.volume = Float(volume)

        rateObserver = player?.observe(\.rate, options: [.new]) { [weak self] player, _ in
            DispatchQueue.main.async {
                let playing = player.rate > 0
                if self?.isPlaying != playing { self?.isPlaying = playing }
            }
        }
        statusObserver = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async { self?.isBuffering = item.status == .unknown }
        }
    }

    func play() {
        player?.play()
        isPlaying = true
        isBuffering = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.isBuffering = false
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        isBuffering = false
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { play() }
    }

    func setVolume(_ vol: Double) {
        volume = vol
        player?.volume = Float(vol)
    }

    // MARK: - Now Playing

    private func scheduleNowPlayingUpdates() {
        fetchNowPlaying()
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            self?.fetchNowPlaying()
        }
    }

    private func fetchNowPlaying() {
        URLSession.shared.dataTask(with: Self.nowPlayingURL) { [weak self] data, _, _ in
            guard let data = data, let html = String(data: data, encoding: .utf8) else { return }
            let artist = self?.extract(html: html, after: #"class="artist-name">"#, before: "</p>")
            let show = self?.extract(html: html, after: #"class="program-title">"#, before: "</p>")
            let songRaw = self?.extract(html: html, after: #"class="song-title""#, before: "</p>")
            let song = songRaw.flatMap { raw -> String? in
                guard let gt = raw.range(of: ">") else { return nil }
                return String(raw[gt.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            DispatchQueue.main.async {
                if let v = artist, !v.isEmpty { self?.currentArtist = v }
                if let v = song, !v.isEmpty { self?.currentSong = v }
                if let v = show, !v.isEmpty { self?.currentShow = v }
            }
        }.resume()
    }

    private func extract(html: String, after start: String, before end: String) -> String? {
        guard let s = html.range(of: start),
              let e = html.range(of: end, range: s.upperBound..<html.endIndex)
        else { return nil }
        return String(html[s.upperBound..<e.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Login Item (LaunchAgent plist — radi bez potpisivanja)

    private var launchAgentURL: URL {
        let bundleID = Bundle.main.bundleIdentifier ?? "rs.naxi.menubar"
        return FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/LaunchAgents/\(bundleID).plist")
    }

    func refreshLoginItemStatus() {
        let enabled = FileManager.default.fileExists(atPath: launchAgentURL.path)
        DispatchQueue.main.async {
            self.launchAtLogin = enabled
            self.loginItemStatus = ""
        }
    }

    func toggleLaunchAtLogin() {
        if launchAtLogin {
            disableLaunchAtLogin()
        } else {
            enableLaunchAtLogin()
        }
        refreshLoginItemStatus()
    }

    private func enableLaunchAtLogin() {
        let appPath = Bundle.main.bundlePath
        let bundleID = Bundle.main.bundleIdentifier ?? "rs.naxi.menubar"

        let plist: [String: Any] = [
            "Label": bundleID,
            "ProgramArguments": ["/usr/bin/open", "-a", appPath],
            "RunAtLoad": true,
            "KeepAlive": false
        ]

        do {
            let dir = launchAgentURL.deletingLastPathComponent()
            try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
            try data.write(to: launchAgentURL)

            let task = Process()
            task.launchPath = "/bin/launchctl"
            task.arguments = ["load", "-w", launchAgentURL.path]
            try task.run()
            task.waitUntilExit()
        } catch {
            DispatchQueue.main.async { self.loginItemStatus = "Greška: \(error.localizedDescription)" }
        }
    }

    private func disableLaunchAtLogin() {
        do {
            let task = Process()
            task.launchPath = "/bin/launchctl"
            task.arguments = ["unload", launchAgentURL.path]
            try task.run()
            task.waitUntilExit()
            try? FileManager.default.removeItem(at: launchAgentURL)
        } catch {
            DispatchQueue.main.async { self.loginItemStatus = "Greška: \(error.localizedDescription)" }
        }
    }

    // MARK: - About

    func showAbout() {
        let credits = NSMutableAttributedString()

        let center = NSMutableParagraphStyle()
        center.alignment = .center

        credits.append(NSAttributedString(string: "Razvio\n", attributes: [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: center
        ]))
        credits.append(NSAttributedString(string: "Dejan Njegić\n", attributes: [
            .font: NSFont.systemFont(ofSize: 13, weight: .semibold),
            .foregroundColor: NSColor.labelColor,
            .paragraphStyle: center
        ]))
        credits.append(NSAttributedString(string: "Nezavisni macOS Developer", attributes: [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: NSColor.secondaryLabelColor,
            .paragraphStyle: center
        ]))

        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Naxi Radio",
            .applicationVersion: "1.0",
            .credits: credits
        ])
    }
}
