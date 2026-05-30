import Cocoa
import ApplicationServices

class AccessibilityHelper {
    static let shared = AccessibilityHelper()
    
    func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func getActiveWindowTitle() -> String? {
        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return nil }
        let appElement = AXUIElementCreateApplication(frontApp.processIdentifier)
        
        var focusedWindow: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute as CFString, &focusedWindow)
        
        if result == .success, let windowElement = focusedWindow as! AXUIElement? {
            var windowTitle: CFTypeRef?
            let titleResult = AXUIElementCopyAttributeValue(windowElement, kAXTitleAttribute as CFString, &windowTitle)
            if titleResult == .success, let title = windowTitle as? String {
                return title
            }
        }
        return nil
    }
}
