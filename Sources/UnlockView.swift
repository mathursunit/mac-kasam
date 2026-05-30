import SwiftUI

struct UnlockView: View {
    @State private var password = ""
    @State private var errorMessage = ""
    var onUnlock: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)
            
            Text("Mac-Kasam Vault")
                .font(.largeTitle)
                .bold()
            
            SecureField("Enter Master Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 300)
                .onSubmit {
                    unlock()
                }
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button("Unlock") {
                unlock()
            }
            .keyboardShortcut(.defaultAction)
        }
        .padding(40)
    }
    
    func unlock() {
        if password.isEmpty {
            errorMessage = "Password cannot be empty"
            return
        }
        CryptoHelper.shared.unlockVault(password: password)
        onUnlock()
    }
}
