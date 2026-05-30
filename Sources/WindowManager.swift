import SwiftUI

class WindowManager {
    static let shared = WindowManager()
    
    var settingsWindow: NSWindow?
    var unlockWindow: NSWindow?
    
    func showSettings() {
        if settingsWindow == nil {
            let view = SettingsView()
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 550, height: 450),
                styleMask: [.titled, .closable, .miniaturizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.setFrameAutosaveName("SettingsWindow")
            window.contentView = NSHostingView(rootView: view)
            window.title = "Settings - Mac-Kasam"
            window.isReleasedWhenClosed = false
            settingsWindow = window
        }
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showUnlock(onUnlock: @escaping () -> Void = {}) {
        if unlockWindow == nil {
            let view = UnlockView { [weak self] in
                self?.unlockWindow?.close()
                onUnlock()
            }
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.contentView = NSHostingView(rootView: view)
            window.title = "Unlock Vault"
            window.isReleasedWhenClosed = false
            unlockWindow = window
        }
        unlockWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
