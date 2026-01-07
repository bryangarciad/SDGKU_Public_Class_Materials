import SwiftUI

struct CharactersGridView: View {
    @EnvironmentObject private var store: CharactersStore
    
    private let columns = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5)
    ]
    
    
    var body: some View {
        Group {
            if store.isInitialLoading && store.characters.isEmpty {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("...Loading")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if let message = store.messageError, store.characters.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.yellow)
                    Text(message)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task { await store.refres() }
                    }
                }
                // Normal Content (Main View / Happy Path)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(store.characters) {characters in
                            
                        }
                    }
                }
            }
        }
    }
}
