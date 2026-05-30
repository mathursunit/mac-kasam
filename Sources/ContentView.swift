import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "lock.shield")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome to Mac-Kasam")
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
    }
}
