import SwiftUI

struct CharacterTile: View {
    let character: RMCharacter
    
    var body: some View {
        VStack(spacing: 4) {
            AsyncImage(url: URL(string: character.image)) { phase in
                switch phase {
                    case .success(let image):
                        image.resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    case .empty:
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.secondary.opacity(0.2))
                            ProgressView()
                        }
                        .frame(width: 70, height: 70)
                    case .failure:
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.secondary)
                            Image(systemName: "photo")
                                .font(.title2)
                                .foregroundColor(.secondary)
                        }
                    @unknown default:
                        EmptyView()
                }
            }
            
            Text(character.name)
                .font(.caption2)
                .lineLimit(1)
                .frame(maxWidth: 70, alignment: .center)
        }
        .frame(maxWidth: 70)
    }
}
