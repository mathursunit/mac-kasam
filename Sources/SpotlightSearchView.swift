import SwiftUI
import KeyboardShortcuts

class SpotlightState: ObservableObject {
    static let shared = SpotlightState()
    @Published var detectedTitle: String = ""
}

struct SpotlightSearchView: View {
    @StateObject private var state = SpotlightState.shared
    @State private var searchText = ""
    @State private var allEntries: [VaultEntry] = []
    
    var filteredResults: [VaultEntry] {
        if searchText.isEmpty {
            let matches = allEntries.filter { entry in
                guard let matchStr = entry.matchWindowTitle, !matchStr.isEmpty else { return false }
                return state.detectedTitle.localizedCaseInsensitiveContains(matchStr)
            }
            let others = allEntries.filter { entry in
                guard let matchStr = entry.matchWindowTitle, !matchStr.isEmpty else { return true }
                return !state.detectedTitle.localizedCaseInsensitiveContains(matchStr)
            }
            return matches + others
        } else {
            return allEntries.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                
                TextField("Search Mac-Kasam...", text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 24, weight: .light))
                    .padding(.vertical, 16)
            }
            .padding(.horizontal, 20)
            
            if !state.detectedTitle.isEmpty {
                HStack {
                    Text("Detected Window:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(state.detectedTitle)
                        .font(.caption)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
            
            if !filteredResults.isEmpty {
                Divider()
                List(filteredResults) { entry in
                    Button(action: { 
                        triggerAutoType(entry)
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(entry.title).font(.headline)
                                Text(entry.username).font(.subheadline).foregroundColor(.gray)
                            }
                            Spacer()
                            Text("Auto-Type ⏎").font(.caption).foregroundColor(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
                .frame(maxHeight: 300)
            } else {
                Text("No entries found.")
                    .foregroundColor(.gray)
                    .padding()
            }
        }
        .background(
            VisualEffectView(material: .hudWindow, blendingMode: .behindWindow)
                .cornerRadius(16)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            self.allEntries = (try? VaultManager.shared.fetchAll()) ?? []
        }
        // Add this to refresh data every time it appears, just in case.
        .onReceive(state.$detectedTitle) { _ in
            self.allEntries = (try? VaultManager.shared.fetchAll()) ?? []
        }
    }
    
    func triggerAutoType(_ entry: VaultEntry) {
        SpotlightWindowController.shared.hide()
        
        var pass = ""
        do {
            pass = try CryptoHelper.shared.decrypt(data: entry.encryptedPassword)
        } catch {
            pass = "DECRYPT_ERROR"
        }
        
        let sequence = "\(entry.username){TAB}\(pass){ENTER}"
        
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 1.5) // Wait for macOS to switch focus back to the target app
            KeystrokeSimulator.shared.typeSequence(sequence)
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
