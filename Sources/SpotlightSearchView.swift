import SwiftUI
import KeyboardShortcuts

struct SpotlightSearchView: View {
    @State private var searchText = ""
    @State private var results: [VaultEntry] = []
    @State private var detectedTitle = ""
    
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
            
            if !detectedTitle.isEmpty {
                HStack {
                    Text("Detected Window:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(detectedTitle)
                        .font(.caption)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
            }
            
            if !results.isEmpty {
                Divider()
                List(results) { entry in
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
            if let title = AccessibilityHelper.shared.getActiveWindowTitle() {
                self.detectedTitle = title
                self.results = (try? VaultManager.shared.findMatches(for: title)) ?? []
            }
        }
    }
    
    func triggerAutoType(_ entry: VaultEntry) {
        SpotlightWindowController.shared.hide()
        guard let pass = entry.getPassword() else { return }
        let sequence = "\(entry.username){TAB}\(pass){ENTER}"
        
        DispatchQueue.global().async {
            Thread.sleep(forTimeInterval: 0.2) // Wait for panel to disappear
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
