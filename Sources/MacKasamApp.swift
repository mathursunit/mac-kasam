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
        
        // Handle initial unlock
        if !SettingsManager.shared.useSimplePrompt, let token = KeychainHelper.shared.getToken() {
            CryptoHelper.shared.unlockVault(password: token)
        } else {
            WindowManager.shared.showUnlock()
        }
    }
}

@main
struct MacKasamApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState()
    
    init() {
        _ = try? VaultManager.shared.setupDatabase()
    }
    
    var body: some Scene {
        MenuBarExtra("MacKasam", systemImage: "lock.shield") {
            Button("Show Settings") {
                WindowManager.shared.showSettings()
            }
            Divider()
            Button("Lock Vault") {
                WindowManager.shared.showUnlock()
            }
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
