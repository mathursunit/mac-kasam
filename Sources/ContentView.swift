import SwiftUI

struct ContentView: View {
    @State private var permissionStatus = "Checking..."
    @State private var lastWindowTitle = "None"
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield")
                .imageScale(.large)
                .font(.system(size: 60))
                .foregroundStyle(.tint)
            
            Text("Mac-Kasam Auto-Type Core Test")
                .font(.headline)
            
            HStack {
                Text("Accessibility Permissions:")
                Text(permissionStatus)
                    .foregroundColor(permissionStatus == "Granted" ? .green : .red)
            }
            
            Button("Request Permissions") {
                let granted = AccessibilityHelper.shared.checkAccessibilityPermissions()
                permissionStatus = granted ? "Granted" : "Denied (Check System Settings)"
            }
            
            Divider()
            
            Text("Last Detected Window: \(lastWindowTitle)")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button("Test Auto-Type (3s delay)") {
                DispatchQueue.global().async {
                    Thread.sleep(forTimeInterval: 3.0)
                    let title = AccessibilityHelper.shared.getActiveWindowTitle() ?? "Unknown"
                    DispatchQueue.main.async {
                        self.lastWindowTitle = title
                    }
                    
                    KeystrokeSimulator.shared.typeSequence("Hello from Mac-Kasam!{ENTER}Testing{TAB}123{ENTER}")
                }
            }
            .buttonStyle(.borderedProminent)
            
            Text("Click 'Test Auto-Type', then quickly click into a TextEdit or browser window.\nIt will detect the title and simulate typing.")
                .font(.caption2)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(minWidth: 400, minHeight: 400)
        .onAppear {
            let granted = AccessibilityHelper.shared.checkAccessibilityPermissions()
            permissionStatus = granted ? "Granted" : "Denied"
        }
    }
}
