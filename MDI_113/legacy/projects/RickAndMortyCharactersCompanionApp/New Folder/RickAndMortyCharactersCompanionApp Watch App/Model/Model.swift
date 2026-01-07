import Foundation

struct RMCharacter: Decodable, Identifiable {
    let id: Int
    let name: String
    let image: String
    let species: String? // Keep it undefined when not available
    let status: String?
}

struct CharactersResponse: Decodable {
    let results: [RMCharacter]
    let info: Info
    
    struct Info: Decodable {
        let count: Int
        let pages: Int
        let next: String?
        let prev: String?
    }
}
