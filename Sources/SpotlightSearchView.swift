import SwiftUI
import KeyboardShortcuts

struct SpotlightSearchView: View {
    @State private var searchText = ""
    @State private var allEntries: [VaultEntry] = []
    
    var filteredResults: [VaultEntry] {
        if searchText.isEmpty {
            return allEntries
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
    }
    
    func triggerAutoType(_ entry: VaultEntry) {
        SpotlightWindowController.shared.hide()
        
        var pass = ""
        do {
            pass = try CryptoHelper.shared.decrypt(data: entry.encryptedPassword)
        } catch {
            pass = "DECRYPT_ERROR"
        }
        
        var sequence = entry.autoTypeSequence
        sequence = sequence.replacingOccurrences(of: "{USERNAME}", with: entry.username)
        sequence = sequence.replacingOccurrences(of: "{PASSWORD}", with: pass)
        
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
