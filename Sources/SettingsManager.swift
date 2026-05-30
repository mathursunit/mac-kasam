import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    @Published var useSimplePrompt: Bool {
        didSet {
            UserDefaults.standard.set(useSimplePrompt, forKey: "useSimplePrompt")
            if useSimplePrompt {
                KeychainHelper.shared.deleteToken()
            }
        }
    }
    
    init() {
        self.useSimplePrompt = UserDefaults.standard.bool(forKey: "useSimplePrompt")
    }
}
