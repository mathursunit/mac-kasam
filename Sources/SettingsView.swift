import SwiftUI

struct SettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    
    var body: some View {
        TabView {
            SecuritySettingsView()
                .tabItem {
                    Label("Security", systemImage: "lock.shield")
                }
            VaultSettingsView()
                .tabItem {
                    Label("Vault", systemImage: "key.fill")
                }
        }
        .padding()
        .frame(width: 550, height: 450)
    }
}

struct SecuritySettingsView: View {
    @ObservedObject var settingsManager = SettingsManager.shared
    @State private var newMasterToken: String = ""
    @State private var showingSaveAlert = false
    
    var body: some View {
        Form {
            Section(header: Text("Master Authentication")) {
                Toggle("Use Simple Prompt (No Keychain)", isOn: $settingsManager.useSimplePrompt)
                
                if !settingsManager.useSimplePrompt {
                    SecureField("Save New Master Password to Keychain", text: $newMasterToken)
                    Button("Save to Keychain") {
                        if !newMasterToken.isEmpty {
                            let success = KeychainHelper.shared.saveToken(newMasterToken)
                            if success {
                                showingSaveAlert = true
                                CryptoHelper.shared.unlockVault(password: newMasterToken)
                                newMasterToken = ""
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .alert("Saved to Keychain", isPresented: $showingSaveAlert) {
            Button("OK", role: .cancel) { }
        }
    }
}

struct VaultSettingsView: View {
    @State private var entries: [VaultEntry] = []
    @State private var showingAddSheet = false
    
    var body: some View {
        VStack {
            List(entries, id: \.id) { entry in
                HStack {
                    VStack(alignment: .leading) {
                        Text(entry.title).font(.headline)
                        Text(entry.autoTypeSequence).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(entry.username).font(.caption)
                }
            }
            
            HStack {
                Button("Add Entry") {
                    showingAddSheet = true
                }
                Button("Refresh") {
                    loadEntries()
                }
            }
            .padding()
        }
        .onAppear { loadEntries() }
        .sheet(isPresented: $showingAddSheet) {
            AddEntryView { loadEntries() }
        }
    }
    
    func loadEntries() {
        entries = (try? VaultManager.shared.fetchAll()) ?? []
    }
}

struct AddEntryView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var title = ""
    @State private var username = ""
    @State private var password = ""
    @State private var autoTypeSequence = "{USERNAME}{TAB}{PASSWORD}{ENTER}"
    
    var onSave: () -> Void
    
    var body: some View {
        Form {
            TextField("Title", text: $title)
            TextField("Username", text: $username)
            SecureField("Password", text: $password)
            TextField("Auto-Type Sequence", text: $autoTypeSequence)
            
            HStack {
                Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                Button("Save") {
                    _ = try? VaultManager.shared.addEntry(title: title, username: username, passwordRaw: password, url: nil, autoTypeSequence: autoTypeSequence)
                    onSave()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 400, height: 300)
    }
}
