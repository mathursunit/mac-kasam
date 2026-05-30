import Cocoa
import SwiftUI

class SpotlightPanel: NSPanel {
    init(contentRect: NSRect) {
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: false
        )
        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
    }
    
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
}

class SpotlightWindowController: NSObject {
    static let shared = SpotlightWindowController()
    private var panel: SpotlightPanel?
    
    func show() {
        if panel == nil {
            let hostingView = NSHostingView(rootView: SpotlightSearchView())
            panel = SpotlightPanel(contentRect: NSRect(x: 0, y: 0, width: 600, height: 400))
            panel?.contentView = hostingView
            panel?.center()
        }
        
        panel?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func hide() {
        panel?.orderOut(nil)
    }
}
