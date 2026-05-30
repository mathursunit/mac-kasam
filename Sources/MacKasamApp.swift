import SwiftUI
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let toggleSpotlight = Self("toggleSpotlight", default: .init(.space, modifiers: [.control, .option]))
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from dock dynamically instead of Info.plist
        NSApp.setActivationPolicy(.accessory)
        
        // Force accessibility prompt on launch if missing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            _ = AccessibilityHelper.shared.checkAccessibilityPermissions()
        }
    }
}

@main
struct MacKasamApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    init() {
        _ = try? VaultManager.shared.setupDatabase()
        // Temporary for testing:
        CryptoHelper.shared.unlockVault(password: "password123")
        if let entries = try? VaultManager.shared.fetchAll(), entries.isEmpty {
            _ = try? VaultManager.shared.addEntry(title: "Test Server", username: "admin", passwordRaw: "secretPass", url: nil, matchWindowTitle: "TextEdit")
        }
    }
    
    var body: some Scene {
        MenuBarExtra("MacKasam", systemImage: "lock.shield") {
            Button("Show Settings") {
                // Implement settings later
            }
            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}

@MainActor
class AppState: ObservableObject {
    init() {
        KeyboardShortcuts.onKeyUp(for: .toggleSpotlight) {
            SpotlightWindowController.shared.show()
        }
    }
}
