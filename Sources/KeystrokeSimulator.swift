import ApplicationServices
import Cocoa

class KeystrokeSimulator {
    static let shared = KeystrokeSimulator()
    
    enum Token {
        case text(String)
        case key(CGKeyCode)
        case delay(Int)
    }
    
    func typeSequence(_ sequence: String) {
        NSSound.beep()
        let tokens = parseSequence(sequence)
        
        for token in tokens {
            switch token {
            case .text(let str):
                typeString(str)
            case .key(let keyCode):
                pressKey(keyCode: keyCode)
            case .delay(let ms):
                Thread.sleep(forTimeInterval: Double(ms) / 1000.0)
            }
        }
        NSSound.beep()
    }
    
    private func parseSequence(_ sequence: String) -> [Token] {
        var tokens: [Token] = []
        var currentText = ""
        var inTag = false
        var tagBuffer = ""
        
        for char in sequence {
            if char == "{" {
                if !currentText.isEmpty { tokens.append(.text(currentText)); currentText = "" }
                inTag = true
                tagBuffer = ""
            } else if char == "}" && inTag {
                inTag = false
                if let specialToken = parseTag(tagBuffer) {
                    tokens.append(specialToken)
                } else {
                    tokens.append(.text("{\(tagBuffer)}"))
                }
            } else if inTag {
                tagBuffer.append(char)
            } else {
                currentText.append(char)
            }
        }
        if !currentText.isEmpty { tokens.append(.text(currentText)) }
        return tokens
    }
    
    private func parseTag(_ tag: String) -> Token? {
        let upperTag = tag.uppercased()
        switch upperTag {
        case "TAB": return .key(0x30)
        case "ENTER": return .key(0x24)
        case "SPACE": return .key(0x31)
        default:
            if upperTag.hasPrefix("DELAY ") {
                if let ms = Int(upperTag.replacingOccurrences(of: "DELAY ", with: "")) {
                    return .delay(ms)
                }
            }
            return nil
        }
    }
    
    private func typeString(_ str: String) {
        let eventSource = CGEventSource(stateID: .hidSystemState)
        let utf16Chars = Array(str.utf16)
        var i = 0
        while i < utf16Chars.count {
            var charCount = 1
            if i + 1 < utf16Chars.count && UTF16.isLeadSurrogate(utf16Chars[i]) && UTF16.isTrailSurrogate(utf16Chars[i+1]) {
                charCount = 2
            }
            let charArray = Array(utf16Chars[i..<i+charCount])
            
            if let eventDown = CGEvent(keyboardEventSource: eventSource, virtualKey: 0, keyDown: true) {
                eventDown.keyboardSetUnicodeString(stringLength: charCount, unicodeString: charArray)
                eventDown.post(tap: .cghidEventTap)
            }
            if let eventUp = CGEvent(keyboardEventSource: eventSource, virtualKey: 0, keyDown: false) {
                eventUp.keyboardSetUnicodeString(stringLength: charCount, unicodeString: charArray)
                eventUp.post(tap: .cghidEventTap)
            }
            i += charCount
            Thread.sleep(forTimeInterval: 0.01)
        }
    }
    
    private func pressKey(keyCode: CGKeyCode) {
        let eventSource = CGEventSource(stateID: .hidSystemState)
        if let eventDown = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: true) {
            eventDown.post(tap: .cghidEventTap)
        }
        if let eventUp = CGEvent(keyboardEventSource: eventSource, virtualKey: keyCode, keyDown: false) {
            eventUp.post(tap: .cghidEventTap)
        }
        Thread.sleep(forTimeInterval: 0.05)
    }
}
