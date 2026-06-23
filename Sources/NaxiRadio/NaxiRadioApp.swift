import SwiftUI

struct NaxiRadioApp: App {
    @StateObject private var state = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(state)
        } label: {
            Image(systemName: state.isPlaying ? "radio.fill" : "radio")
        }
        .menuBarExtraStyle(.window)
    }
}
