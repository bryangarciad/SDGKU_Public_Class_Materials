import SwiftUI

struct CharactersGridView: View {
    @EnvironmentObject private var store: RMCharactersStore

    // Defining Number Of Columns For Grid
    private let colums = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
    ]
    
    var body: some View {
        Group {
            if store.isInitialLoading && store.characters.isEmpty {
                VStack(spacing: 8) {
                    ProgressView()
                    Text("Loading")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if let message = store.errorMessage, store.characters.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundStyle(.yellow)
                    Text(message)
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: colums, spacing: 6) {
                        ForEach(store.characters.indices, id: \.self) { idx in
                            let character = store.characters[idx]
                            
                            NavigationLink {
                                CharacterDetailsView()
                            } label: {
                                CharacterTileView(character: character)
                            }
                            .buttonStyle(.plain)
                            .task { await store.loadMoreIfNeeded(idx: idx) }
                        }
                    }
                }
            }
        }
    }
}
